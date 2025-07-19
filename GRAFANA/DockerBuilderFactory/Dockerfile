# ╔══════════════════════════════════════════════════╗
# ║# Grafana entreprise with no vulnerabilities      ║
# ║- golang:1.24.2-alpine3.21                        ║
# ╚══════════════════════════════════════════════════╝

FROM golang@sha256:3077e12cda6debf8a9eba8eba0b6b4efe6f9c17295a18e3883cc5797d1688acb AS builder
LABEL stage="builder"
ENV CGO_ENABLED=0

RUN apk add --no-cache git=2.47.2-r0 && \
    git clone https://github.com/tianon/gosu.git /src/gosu

WORKDIR /src/gosu
# Compiler gosu avec CGO désactivé pour un binaire statique
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/gosu

# Étape 2 : Image finale Grafana sans vulnérabilités
FROM alpine@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474

USER root
# Installer les dépendances, créer l'utilisateur Grafana et préparer les répertoires
RUN  apk add --no-cache curl shadow ca-certificates && \
    adduser -D -u 472 -g 472 grafana && \
    mkdir -p /usr/share/grafana/tls /usr/share/grafana/shared && \
    chown -R grafana:grafana /usr/share/grafana && \
    chmod -R 755 /usr/share/grafana
    
# Copier le binaire gosu compilé
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

RUN groupadd ssl-cert && \
    usermod -aG ssl-cert grafana && \
    chown -R grafana:ssl-cert /usr/share/grafana/tls && \
    mkdir -p /usr/local/share/ca-certificates

RUN curl -L -s https://dl.grafana.com/enterprise/release/grafana-enterprise-12.0.0.linux-amd64.tar.gz -o grafana.tar.gz && \
    tar -zxf grafana.tar.gz -C  /usr/share/grafana --strip-components=1 && \
    rm grafana.tar.gz

   
WORKDIR /usr/share/grafana

COPY Certs/backend.crt  /usr/share/grafana/tls/backend.crt
COPY Certs/backend.key  /usr/share/grafana/tls/backend.key
COPY Certs/vault-ca.crt /usr/local/share/ca-certificates/vault-ca.crt
     
RUN chown -R grafana:grafana /usr/share/grafana/* && \
    chmod 600 /usr/share/grafana/tls/backend.key && \
    update-ca-certificates && \
    cp /usr/local/share/ca-certificates/vault-ca.crt /usr/share/grafana/tls/vault-ca.crt


LABEL maintainer="lamboartur94@gmail.com" \
    org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/GRAFANA/DockerBuilderFactory" \
    org.opencontainers.image.os="linux" \
    org.opencontainers.image.architecture="amd64" \
    org.opencontainers.image.version="v2" \
    org.opencontainers.image.created="2025-04-21" \
    org.opencontainers.image.description="Grafana Entreprise with no vulnerabilities" \
    org.opencontainers.image.vendor="LAMBOFIRSTECH"

USER grafana
# Expose TCP listener port
EXPOSE 3000