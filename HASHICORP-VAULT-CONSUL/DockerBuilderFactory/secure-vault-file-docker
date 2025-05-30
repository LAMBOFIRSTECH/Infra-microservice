# ╔══════════════════════════════════════════════════╗
# ║# vault hashicorp 1.19.3 with no vulnerabilities  ║
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

# Étape 2 : Image finale vault sans vulnérabilités
FROM alpine@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474

# Installer les dépendances, créer l'utilisateur vault et préparer les répertoires
RUN apk add --no-cache  curl shadow ca-certificates && \
    adduser -D -u 1000 -g 1000 vault

# Copier le binaire gosu compilé
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

LABEL maintainer="lamboartur94@gmail.com" \
    org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/HASHICORP-VAULT-CONSUL/DockerBuilderFactory" \
    org.opencontainers.image.os="linux" \
    org.opencontainers.image.architecture="amd64" \
    org.opencontainers.image.version="v2" \
    org.opencontainers.image.created="2025-04-14" \
    org.opencontainers.image.description="vault hashicorp 1.19.3 with no vulnerabilities" \
    org.opencontainers.image.vendor="LAMBOFIRSTECH"
ENV VERSION=1.19.3

ADD https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_linux_amd64.zip /tmp/
ADD https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_SHA256SUMS      /tmp/
ADD https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_SHA256SUMS.sig  /tmp/

ENV GOVER=1.24.3
RUN curl -sSL "https://go.dev/dl/go${GOVER}.linux-amd64.tar.gz" | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:$PATH"

WORKDIR /tmp/
COPY main.go /tmp/

# Créer un répertoire pour le projet Go et initialiser le module
RUN mkdir -p /tmp/go_vault && \
    cp /tmp/main.go /tmp/go_vault/ && \
    cd /tmp/go_vault && \
    go mod init deps_vuln && \
    # Ajouter les modules nécessaires et récupérer les dépendances
    go get github.com/go-jose/go-jose/v3 && \
    go get github.com/golang-jwt/jwt/v4 && \
    go get golang.org/x/crypto/ssh && \
    go mod tidy && \
    # Exécuter le code Go pour tester les modules
    go run /tmp/go_vault/main.go

RUN apk --update add --virtual verify gpgme \
    && gpg --keyserver keyserver.ubuntu.com --recv-key 0x72D7468F \
    && gpg --verify /tmp/vault_${VERSION}_SHA256SUMS.sig \
    && apk del verify \
    && cat vault_${VERSION}_SHA256SUMS | grep linux_amd64 | sha256sum -c \
    && unzip vault_${VERSION}_linux_amd64.zip \
    && mv vault /usr/local/bin/ \
    && rm -rf /var/cache/apk/* \
    && rm /tmp/vault_1.19.3_*

WORKDIR /vault

COPY vault-init.sh /vault/vault-init.sh
COPY vault-auth.sh /vault/vault-auth.sh
COPY vault-server-config.hcl /vault/config/vault-server-config.hcl
COPY vault-agent-config.hcl /vault/config/vault-agent-config.hcl

RUN mkdir -p /opt/vault/tls && \
    groupadd ssl-cert && \
    usermod -aG ssl-cert vault && \
    mkdir -p /usr/local/share/ca-certificates && \
    mkdir -p /vault/shared

COPY Certs/backend.crt  /opt/vault/tls/backend.crt
COPY Certs/backend.key  /opt/vault/tls/backend.key
COPY Certs/vault-ca.crt /usr/local/share/ca-certificates/vault-ca.crt
     
RUN chmod -R 755 /vault && \
    chown -R vault:vault /vault && \
    chown -R vault:vault /vault/* && \
    chown -R vault:ssl-cert /opt/vault/tls && \
    chmod 600 /opt/vault/tls/backend.key && \
    update-ca-certificates && \
    cp /usr/local/share/ca-certificates/vault-ca.crt /opt/vault/tls/vault-ca.crt

USER vault
# Expose TCP listener port
EXPOSE 8200