# Deploy do Aura na VPS Hostinger (Debian + Docker + nginx existente)

Roteiro de deploy reaproveitando o nginx + certs Let's Encrypt ja
configurados em `numik.com.br`.

## Visao geral

```
Internet -> nginx (host, :443 SSL) -> docker container aura (127.0.0.1:8001)
                                            |
                                            v
                                   docker container postgres (rede interna)
```

## Pre-requisitos
- VPS Debian 13 com Docker e nginx ja instalados
- Cert SSL valido para numik.com.br em /etc/letsencrypt/live/numik.com.br/
- Acesso root via SSH

## Bloco unico (copiar e colar inteiro no SSH como root)

Veja o arquivo `docs/deploy/deploy.sh` para o script completo.

## O que o script faz
1. Para o site antigo (gunicorn + nginx config site3d)
2. Clona o repo na branch deploy/hostinger em /opt/aura
3. Cria .env.production com SECRET_KEY aleatoria e senhas fortes
4. Build dos containers Docker
5. Sobe Postgres e API
6. Cria superuser do admin
7. Substitui config nginx para apontar para o Aura
8. Recarrega nginx
9. Testa o endpoint

## Como atualizar depois (sem refazer tudo)

```bash
cd /opt/aura
git pull origin deploy/hostinger
docker compose -f docker-compose.prod.yml up -d --build
```

## Como ver logs

```bash
cd /opt/aura
docker compose -f docker-compose.prod.yml logs -f api    # API
docker compose -f docker-compose.prod.yml logs -f db     # Postgres
tail -f /var/log/nginx/aura.access.log                   # nginx
```

## Como voltar para o site antigo (rollback)

```bash
systemctl stop nginx
rm /etc/nginx/sites-enabled/aura
ln -sf /etc/nginx/sites-available/site3d /etc/nginx/sites-enabled/site3d
# inicia o gunicorn antigo (se tinha service systemd)
systemctl start gunicorn-site3d  # ou comando manual
systemctl start nginx
```

## App Flutter apontando para producao

```bash
flutter run --dart-define=API_URL=https://numik.com.br/api
# Build de produção:
flutter build apk --release --dart-define=API_URL=https://numik.com.br/api
```
