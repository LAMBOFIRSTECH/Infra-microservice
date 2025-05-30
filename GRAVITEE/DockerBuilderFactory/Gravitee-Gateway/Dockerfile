# ╔══════════════════════════════════════════════════╗
# ║# Elasticsearch-Gravitee with no vulnerabilities  ║
# ║- golang:alpine3.21                               ║
# ╚══════════════════════════════════════════════════╝

# Étape 1 : build de gosu statique sans vulnérabilités
FROM golang:alpine3.21 AS builder

LABEL stage="builder"

# Désactiver CGO pour un binaire statique
ENV CGO_ENABLED=0

RUN apk add --no-cache git && \
    rm -rf /var/cache/apk/*

# Cloner Gosu depuis le dépôt officiel
RUN git clone https://github.com/tianon/gosu.git /src/gosu

WORKDIR /src/gosu
# Compiler gosu avec CGO désactivé pour un binaire statique
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/gosu

# Étape 2 : image finale elasticsearch sans vulnérabilités
FROM alpine@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474

LABEL maintainer="lamboartur94@gmail.com" \
    org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/GRAVITEE/DockerBuilderFactory/Elasticsearch" \
    org.opencontainers.image.os="linux" \
    org.opencontainers.image.architecture="amd64" \
    org.opencontainers.image.version="v2" \
    org.opencontainers.image.created="2025-05-27" \
    org.opencontainers.image.description="Elasticsearch 4.0.6-1 with static gosu and no vulnerabilities" \
    org.opencontainers.image.vendor="LAMBOFIRSTECH"

# Copier gosu compilé
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu

RUN apk add --no-cache  curl shadow ca-certificates && \
apk update && apk upgrade --no-cache && \
    adduser -D -u 1000 -g 1000 elk && \
    mkdir -p /opt/elasticsearch /opt/elasticsearch/tls /var/log/elasticsearch && \
    curl -L -s https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-9.0.1-linux-x86_64.tar.gz -o elastic.tar.gz && \
    tar -xzf elastic.tar.gz -C /opt/elasticsearch --strip-components=1 && \
    rm elastic.tar.gz && \
    chmod +x /usr/local/bin/gosu && \
    groupadd ssl-cert && \
    usermod -aG ssl-cert elk

WORKDIR /opt/elasticsearch
COPY Certs/ /opt/elasticsearch/tls/

RUN apk update && apk upgrade --no-cache \
    && chown -R elk: /opt/elasticsearch \
    && chown -R elk: /var/log/elasticsearch \
    && chown -R elk:ssl-cert /opt/elasticsearch/tls \
    && chmod 600 /opt/elasticsearch/tls/backend.pem \
    && cp /opt/elasticsearch/tls/vault-ca.crt /usr/local/share/ca-certificates/vault-ca.crt \
    && update-ca-certificates \
    && chown -R elk:ssl-cert /opt/elasticsearch/tls/vault-ca.crt

USER elk
EXPOSE 9200
CMD ["/bin/sh"]
