#!/bin/bash
# Aura - Deploy script para VPS Hostinger
# Roda como root. Copiar e colar inteiro no SSH.
#
# Pre-requisitos ja verificados:
# - Debian 13, Docker 26+, nginx 1.26+, cert /etc/letsencrypt/live/numik.com.br

set -e
echo "##########################################################"
echo "# AURA - Deploy Hostinger - $(date)"
echo "##########################################################"

# -----------------------------------------------------
# Etapa 1: parar o site antigo (gunicorn site_vendas_3d)
# -----------------------------------------------------
echo "[1/8] Parando site_vendas_3d (gunicorn)..."
# Tenta primeiro via systemd
for svc in $(systemctl list-units --type=service --all --no-legend 2>/dev/null \
              | awk '{print $1}' | grep -iE 'site.*vendas|vendas.*3d|site3d|gunicorn'); do
  echo "  Parando service: $svc"
  systemctl stop "$svc" 2>/dev/null || true
  systemctl disable "$svc" 2>/dev/null || true
done
# Fallback: mata qualquer gunicorn do site_vendas_3d
pkill -f "site_vendas_3d.*gunicorn" 2>/dev/null || true
sleep 1
if ss -tln | grep -q ':8000 '; then
  echo "  AVISO: porta 8000 ainda em uso. Saindo do script."
  echo "  Investigar: ss -tlnp | grep :8000"
  exit 1
fi
echo "  OK - porta 8000 livre."

# -----------------------------------------------------
# Etapa 2: clonar/atualizar repo em /opt/aura
# -----------------------------------------------------
echo "[2/8] Clonando repo em /opt/aura..."
if [ -d /opt/aura/.git ]; then
  cd /opt/aura
  git fetch origin
  git checkout deploy/hostinger
  git pull origin deploy/hostinger
else
  git clone -b deploy/hostinger https://github.com/Namem/HackHero2026.git /opt/aura
  cd /opt/aura
fi
echo "  OK - branch: $(git branch --show-current), commit: $(git rev-parse --short HEAD)"

# -----------------------------------------------------
# Etapa 3: criar .env.production (se nao existir)
# -----------------------------------------------------
echo "[3/8] Configurando .env.production..."
ENV_FILE=/opt/aura/backend/.env.production
if [ ! -f "$ENV_FILE" ]; then
  SECRET=$(openssl rand -hex 32)
  DBPASS=$(openssl rand -hex 16)
  cat > "$ENV_FILE" <<EOF
DJANGO_SECRET_KEY=$SECRET
DEBUG=False
ALLOWED_HOSTS=numik.com.br,www.numik.com.br
CSRF_TRUSTED_ORIGINS=https://numik.com.br,https://www.numik.com.br
DB_NAME=aura
DB_USER=aura
DB_PASSWORD=$DBPASS
DB_HOST=db
DB_PORT=5432
GEMINI_API_KEY=
EOF
  chmod 600 "$ENV_FILE"
  echo "  OK - $ENV_FILE criado com SECRET_KEY e DB_PASSWORD aleatorios"
  echo "  (Para adicionar GEMINI_API_KEY depois: nano $ENV_FILE)"
else
  echo "  OK - $ENV_FILE ja existe, mantendo"
fi

# -----------------------------------------------------
# Etapa 4: build dos containers
# -----------------------------------------------------
echo "[4/8] Build dos containers Aura (pode demorar 2-3min na primeira vez)..."
cd /opt/aura
docker compose -f docker-compose.prod.yml build

# -----------------------------------------------------
# Etapa 5: subir db + api
# -----------------------------------------------------
echo "[5/8] Subindo containers..."
docker compose -f docker-compose.prod.yml up -d
echo "  Aguardando API ficar pronta..."
for i in 1 2 3 4 5 6 7 8 9 10; do
  if curl -sf http://127.0.0.1:8001/api/ > /dev/null 2>&1 || \
     curl -s http://127.0.0.1:8001/admin/ | grep -q -i 'django\|login\|csrf'; then
    echo "  OK - API respondendo em 127.0.0.1:8001 (tentativa $i)"
    break
  fi
  sleep 3
  if [ "$i" = "10" ]; then
    echo "  AVISO: API nao respondeu em 30s. Veja logs:"
    docker compose -f docker-compose.prod.yml logs --tail=30 api
    exit 1
  fi
done

# -----------------------------------------------------
# Etapa 6: trocar config nginx
# -----------------------------------------------------
echo "[6/8] Configurando nginx para apontar para Aura..."
# Backup do antigo
if [ -f /etc/nginx/sites-enabled/site3d ]; then
  cp /etc/nginx/sites-enabled/site3d /etc/nginx/sites-available/site3d.bak.$(date +%Y%m%d-%H%M%S)
  rm /etc/nginx/sites-enabled/site3d
fi
# Copia o novo config
cp /opt/aura/docs/deploy/nginx-aura.conf /etc/nginx/sites-available/aura
ln -sf /etc/nginx/sites-available/aura /etc/nginx/sites-enabled/aura
# Testa
if nginx -t 2>&1 | grep -q 'syntax is ok'; then
  systemctl reload nginx
  echo "  OK - nginx recarregado"
else
  echo "  ERRO no config nginx, revertendo..."
  rm /etc/nginx/sites-enabled/aura
  ln -sf /etc/nginx/sites-available/site3d /etc/nginx/sites-enabled/site3d
  nginx -t && systemctl reload nginx
  exit 1
fi

# -----------------------------------------------------
# Etapa 7: criar superuser (interativo, opcional)
# -----------------------------------------------------
echo "[7/8] Criar superuser do Django admin? (pode pular com Ctrl+C)"
echo "  Pular: rode depois com:"
echo "    cd /opt/aura && docker compose -f docker-compose.prod.yml exec api python manage.py createsuperuser"
read -p "  Criar agora? [y/N] " yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
  docker compose -f docker-compose.prod.yml exec api python manage.py createsuperuser
fi

# -----------------------------------------------------
# Etapa 8: testes finais
# -----------------------------------------------------
echo "[8/8] Testes finais..."
echo "  Local (127.0.0.1:8001/api/):"
curl -sI http://127.0.0.1:8001/api/ | head -3
echo ""
echo "  Publico (https://numik.com.br/api/):"
curl -sI https://numik.com.br/api/ | head -3
echo ""
echo "  Admin: https://numik.com.br/admin/"

echo ""
echo "##########################################################"
echo "# DEPLOY CONCLUIDO"
echo "##########################################################"
echo ""
echo "Comandos uteis:"
echo "  Logs API:    docker compose -f /opt/aura/docker-compose.prod.yml logs -f api"
echo "  Logs DB:     docker compose -f /opt/aura/docker-compose.prod.yml logs -f db"
echo "  Restart:     docker compose -f /opt/aura/docker-compose.prod.yml restart api"
echo "  Atualizar:   cd /opt/aura && git pull && docker compose -f docker-compose.prod.yml up -d --build"
echo ""
echo "App Flutter aponta para: https://numik.com.br/api"
echo "  flutter run --dart-define=API_URL=https://numik.com.br/api"
echo ""
