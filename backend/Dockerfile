FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

WORKDIR /app

# Instala dependências do sistema necessárias para psycopg2/Pillow
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Garante que entrypoint é executável (Windows pode perder esse bit)
RUN chmod +x /app/entrypoint.sh 2>/dev/null || true

EXPOSE 8000

# Comando padrão (sobrescrito em docker-compose.prod.yml)
CMD ["gunicorn", "vigilia.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
