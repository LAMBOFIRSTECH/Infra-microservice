# ╔══════════════════════════════════════════════════╗
# ║ Redis Caching alpine avec gosu et sécurité       ║
# ║ - Base: golang:1.24.2-alpine3.21                 ║
# ╚══════════════════════════════════════════════════╝

########## Étape 1 : Compilation de gosu ##########
FROM golang:alpine3.21 AS builder
LABEL stage="builder"
ENV CGO_ENABLED=0

# Installer git sans forcer une version précise
RUN apk add --no-cache git && \
    git clone https://github.com/tianon/gosu.git /go/gosu

WORKDIR /go/gosu
RUN go build -ldflags="-s -w" -o /usr/local/bin/gosu

########## Étape 2 : Image finale sécurisée ##########
FROM alpine@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474

# Installer les outils nécessaires (curl, shadow, etc.)
RUN apk add --no-cache curl shadow ca-certificates && \
    apk add --update redis && \
    mkdir -p /opt/redis && \
    adduser -D -u 1000 -g 1000 redis-service

# Copier le binaire gosu compilé
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

LABEL maintainer="lamboartur94@gmail.com" \
    org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/1-DEV/DEPLOYMENT/redis/DockerBuilderFactory" \
    org.opencontainers.image.os="linux" \
    org.opencontainers.image.architecture="amd64" \
    org.opencontainers.image.version="v2" \
    org.opencontainers.image.created="2025-07-11" \
    org.opencontainers.image.description="Redis cache service Alpine version with no vulnerabilities" \
    org.opencontainers.image.vendor="LAMBOFIRSTECH"

WORKDIR /opt/redis

# Préparer les répertoires TLS et les certificats
RUN mkdir -p /opt/redis/tls && \
    groupadd ssl-cert && \
    usermod -aG ssl-cert redis-service && \
    mkdir -p /usr/local/share/ca-certificates && \
    touch /opt/redis/redis.conf

# Copie des certificats (doivent exister dans le contexte Docker)
COPY Certs/backend.crt  /opt/redis/tls/backend.crt
COPY Certs/backend.key  /opt/redis/tls/backend.key
COPY Certs/vault-ca.crt /usr/local/share/ca-certificates/vault-ca.crt
COPY redis.conf  /opt/redis/redis.conf

# Appliquer les bons droits
RUN chmod -R 755 /opt/redis && \
    chown -R redis-service: /opt/redis  && \
    chown redis-service:redis-service /opt/redis/redis.conf && \
    chmod 600 /opt/redis/redis.conf && \
    chown -R redis-service:ssl-cert /opt/redis/tls && \
    chmod 600 /opt/redis/tls/backend.key && \
    update-ca-certificates && \
    cp /usr/local/share/ca-certificates/vault-ca.crt /opt/redis/tls/vault-ca.crt && \
    chown redis-service:ssl-cert /opt/redis/tls/vault-ca.crt

# Passer à l'utilisateur non-root
USER redis-service

# Port Redis
EXPOSE 6379
