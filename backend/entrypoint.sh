#!/bin/sh
set -e

echo "[entrypoint] Aguardando Postgres em ${DB_HOST}:${DB_PORT}..."
until python -c "import psycopg2, os; psycopg2.connect(host=os.environ['DB_HOST'], port=os.environ['DB_PORT'], user=os.environ['DB_USER'], password=os.environ['DB_PASSWORD'], dbname=os.environ['DB_NAME'])" 2>/dev/null; do
  echo "[entrypoint] DB indisponivel, tentando em 2s..."
  sleep 2
done
echo "[entrypoint] DB conectado."

echo "[entrypoint] Rodando migracoes..."
python manage.py migrate --noinput

echo "[entrypoint] Coletando arquivos estaticos..."
python manage.py collectstatic --noinput --clear

echo "[entrypoint] Iniciando gunicorn na porta 8000..."
exec gunicorn vigilia.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 3 \
  --timeout 60 \
  --access-logfile - \
  --error-logfile -
