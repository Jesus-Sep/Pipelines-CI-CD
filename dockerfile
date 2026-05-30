# =========================
# 🏗️ ETAPA 1: BUILD
# =========================
FROM python:3.13-slim AS builder

WORKDIR /app

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar uv
RUN pip install --no-cache-dir uv

# Copiar archivos de dependencias primero (mejor cache)
COPY pyproject.toml uv.lock* ./

# Crear entorno virtual e instalar dependencias
RUN uv venv /opt/venv && \
    uv pip install --python /opt/venv/bin/python -e .


# =========================
# 🚀 ETAPA 2: RUNTIME
# =========================
FROM python:3.13-slim

WORKDIR /app

# Dependencias necesarias en runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copiar entorno virtual desde builder
COPY --from=builder /opt/venv /opt/venv

# Copiar proyecto
COPY . .

# Variables de entorno
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Puerto Django
EXPOSE 8000

# Healthcheck (opcional pero pedido en tu tarea)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health/')"
