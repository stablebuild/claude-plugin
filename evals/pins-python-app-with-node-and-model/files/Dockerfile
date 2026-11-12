FROM python:3.12-slim

RUN apt-get update && apt-get install -y curl git ca-certificates gnupg && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs

RUN curl -fsSL -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.44.3/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq

RUN git clone https://github.com/libvips/libvips /opt/libvips && \
    cd /opt/libvips && \
    git checkout 2be083adf2fcf3de5da393a748339bd103960cd3

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY frontend/package.json frontend/package-lock.json ./frontend/
RUN cd frontend && npm ci

COPY . .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
