#!/bin/bash
# Aura - Deploy script para VPS Hostinger
# Roda como root. Copiar e colar inteiro no SSH.
#
# Pre-requisitos:
# - Debian 13, Docker 26+, nginx 1.26+, cert /etc/letsencrypt/live/numik.com.br

set -e
echo "##########################################################"
echo "# AURA - Deploy Hostinger - $(date)"
echo "##########################################################"

# -----------------------------------------------------
# Etapa 1: parar o site antigo (gunicorn site_vendas_3d)
# -----------------------------------------------------
echo "[1/8] Parando site_vendas_3d (gunicorn)..."
for svc in $(systemctl list-units --type=service --all --no-legend 2>/dev/null \
              | awk '{print $1}' | grep -iE 'site.*vendas|vendas.*3d|site3d|gunicorn'); do
  echo "  Parando service: $svc"
  systemctl stop "$svc" 2>/dev/null || true
  systemctl disable "$svc" 2>/dev/null || true
done
pkill -f "site_vendas_3d.*gunicorn" 2>/dev/null || true
sleep 1
if ss -tln | grep -q ':8000 '; then
  echo "  AVISO: porta 8000 ainda em uso. Saindo do script."
  exit 1
fi
echo "  OK - porta 8000 livre."

# -----------------------------------------------------
# Etapa 2: clonar/atualizar repo em /opt/aura
# -----------------------------------------------------
echo "[2/8] Clonando/atualizando repo em /opt/aura..."
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
# Etapa 3: .env.production - cria se nao existir
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

POSTGRES_USER=aura
POSTGRES_PASSWORD=$DBPASS
POSTGRES_DB=aura

DB_NAME=aura
DB_USER=aura
DB_PASSWORD=$DBPASS
DB_HOST=db
DB_PORT=5432

GEMINI_API_KEY=
EOF
  chmod 600 "$ENV_FILE"
  echo "  OK - $ENV_FILE criado com SECRET_KEY e DB_PASSWORD aleatorios"
else
  echo "  $ENV_FILE ja existe - validando..."
  # Garante que POSTGRES_* existem (necessario para o container postgres)
  if ! grep -q '^POSTGRES_USER=' "$ENV_FILE"; then
    echo "  AVISO: faltam POSTGRES_USER/PASSWORD/DB no env. Adicionando do DB_*..."
    DBPASS=$(grep '^DB_PASSWORD=' "$ENV_FILE" | cut -d= -f2-)
    if [ -z "$DBPASS" ]; then
      DBPASS=$(openssl rand -hex 16)
      echo "DB_PASSWORD=$DBPASS" >> "$ENV_FILE"
    fi
    cat >> "$ENV_FILE" <<EOF

POSTGRES_USER=aura
POSTGRES_PASSWORD=$DBPASS
POSTGRES_DB=aura
EOF
  fi
  echo "  OK - $ENV_FILE atualizado"
fi

# -----------------------------------------------------
# Etapa 4: limpar deploys anteriores (importante!)
# -----------------------------------------------------
echo "[4/8] Limpando deploys anteriores (se existirem)..."
cd /opt/aura
docker compose -f docker-compose.prod.yml down -v 2>/dev/null || true
echo "  OK - ambientes antigos removidos (incluindo volumes vazios do Postgres)"

# -----------------------------------------------------
# Etapa 5: build + up dos containers
# -----------------------------------------------------
echo "[5/8] Build + up dos containers..."
docker compose -f docker-compose.prod.yml up -d --build

echo "  Aguardando API ficar pronta..."
for i in $(seq 1 30); do
  if curl -sf -o /dev/null -w "%{http_code}" http://127.0.0.1:8001/api/ 2>/dev/null | grep -qE '^(200|301|302|401|403|404)$'; then
    echo "  OK - API respondendo em 127.0.0.1:8001 (tentativa $i)"
    break
  fi
  if [ "$i" = "30" ]; then
    echo "  ERRO: API nao respondeu em 90s. Logs:"
    docker compose -f docker-compose.prod.yml logs --tail=40 api
    exit 1
  fi
  sleep 3
done

# -----------------------------------------------------
# Etapa 6: trocar config nginx
# -----------------------------------------------------
echo "[6/8] Configurando nginx para apontar para Aura..."
if [ -f /etc/nginx/sites-enabled/site3d ]; then
  cp /etc/nginx/sites-available/site3d /etc/nginx/sites-available/site3d.bak.$(date +%Y%m%d-%H%M%S) 2>/dev/null || true
  rm /etc/nginx/sites-enabled/site3d
fi
cp /opt/aura/docs/deploy/nginx-aura.conf /etc/nginx/sites-available/aura
ln -sf /etc/nginx/sites-available/aura /etc/nginx/sites-enabled/aura

if nginx -t 2>&1 | grep -q 'syntax is ok'; then
  systemctl reload nginx
  echo "  OK - nginx recarregado"
else
  echo "  ERRO no config nginx, revertendo..."
  rm /etc/nginx/sites-enabled/aura
  ln -sf /etc/nginx/sites-available/site3d /etc/nginx/sites-enabled/site3d 2>/dev/null || true
  nginx -t && systemctl reload nginx
  exit 1
fi

# -----------------------------------------------------
# Etapa 7: criar superuser (opcional)
# -----------------------------------------------------
echo "[7/8] Criar superuser do Django admin? (Ctrl+C para pular)"
echo "  Para criar depois manualmente:"
echo "    cd /opt/aura && docker compose -f docker-compose.prod.yml exec api python manage.py createsuperuser"
read -p "  Criar agora? [y/N] " yn
if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
  docker compose -f docker-compose.prod.yml exec api python manage.py createsuperuser
fi

# -----------------------------------------------------
# Etapa 8: testes
# -----------------------------------------------------
echo "[8/8] Testes finais..."
echo "  --- Local (127.0.0.1:8001) ---"
curl -sI http://127.0.0.1:8001/api/ | head -3
echo ""
echo "  --- Publico (https://numik.com.br) ---"
curl -sI https://numik.com.br/api/ | head -3
echo ""
echo "##########################################################"
echo "# DEPLOY CONCLUIDO"
echo "##########################################################"
echo ""
echo "Comandos uteis:"
echo "  Logs API:    docker compose -f /opt/aura/docker-compose.prod.yml logs -f api"
echo "  Logs DB:     docker compose -f /opt/aura/docker-compose.prod.yml logs -f db"
echo "  Restart:     docker compose -f /opt/aura/docker-compose.prod.yml restart api"
echo "  Atualizar:   cd /opt/aura && git pull && bash docs/deploy/deploy.sh"
echo ""
echo "URLs:"
echo "  API:    https://numik.com.br/api/"
echo "  Admin:  https://numik.com.br/admin/"
echo ""
echo "App Flutter para producao:"
echo "  flutter run --dart-define=API_URL=https://numik.com.br/api"
echo ""
