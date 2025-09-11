# ╔══════════════════════════════════════════════════╗
# ║# Nomad hashicorp 1.10.4 with no vulnerabilities  ║
# ║- golang:1.24.6-alpine3.21                        ║
# ╚══════════════════════════════════════════════════╝

FROM golang@sha256:1b26b8fd46237d69f526bd41df124cc9bbfc58e9b1f85267f708c58008b92843 AS builder
LABEL stage="builder"
ENV CGO_ENABLED=0

RUN apk add --no-cache git && \
   git clone https://github.com/tianon/gosu.git /src/gosu

WORKDIR /src/gosu
# Compiler gosu avec CGO désactivé pour un binaire statique
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/gosu

# Étape 2 : Image finale nomad sans vulnérabilités
FROM alpine@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474

# Installer les dépendances, créer l'utilisateur nomad et préparer les répertoires
RUN apk add --no-cache  curl shadow ca-certificates && \
    adduser -D -u 1000 -g 1000 nomad

# Copier le binaire gosu compilé
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu

LABEL maintainer="lamboartur94@gmail.com" \
    org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/HASHICORP-VAULT-CONSUL/DockerBuilderFactory" \
    org.opencontainers.image.os="linux" \
    org.opencontainers.image.architecture="amd64" \
    org.opencontainers.image.version="v2" \
    org.opencontainers.image.created="2025-09-10" \
    org.opencontainers.image.description="nomad hashicorp 1.10.4 with no vulnerabilities" \
    org.opencontainers.image.vendor="LAMBOFIRSTECH"
ENV VERSION=1.10.4

ADD https://releases.hashicorp.com/nomad/${VERSION}/nomad_${VERSION}_linux_amd64.zip /tmp/
ADD https://releases.hashicorp.com/nomad/${VERSION}/nomad_${VERSION}_SHA256SUMS      /tmp/
ADD https://releases.hashicorp.com/nomad/${VERSION}/nomad_${VERSION}_SHA256SUMS.sig  /tmp/

ENV GOVER=1.24.6
RUN curl -sSL "https://go.dev/dl/go${GOVER}.linux-amd64.tar.gz" | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:$PATH"

WORKDIR /tmp/
COPY main.go /tmp/

# Créer un répertoire pour le projet Go et initialiser le module
RUN mkdir -p /tmp/go_nomad && \
    cp /tmp/main.go /tmp/go_nomad/ && \
    cd /tmp/go_nomad && \
    go mod init deps_vuln && \
    go get github.com/go-jose/go-jose/v3 && \
    go get github.com/golang-jwt/jwt/v4 && \
    go get golang.org/x/crypto/ssh && \
    go mod tidy && \
    go run /tmp/go_nomad/main.go

RUN apk --update add --virtual verify gpgme \
    && gpg --keyserver keyserver.ubuntu.com --recv-key 0x72D7468F \
    && gpg --verify /tmp/nomad_${VERSION}_SHA256SUMS.sig \
    && apk del verify \
    && cat nomad_${VERSION}_SHA256SUMS | grep linux_amd64 | sha256sum -c \
    && unzip nomad_${VERSION}_linux_amd64.zip \
    && mv nomad /usr/local/bin/ \
    && rm -rf /var/cache/apk/* \
    && rm /tmp/nomad_1.10.4_*

WORKDIR /nomad

RUN mkdir -p /opt/nomad/tls && \
    groupadd ssl-cert && \
    usermod -aG ssl-cert nomad && \
    mkdir -p /usr/local/share/ca-certificates

COPY nomad-server-config.hcl /nomad/nomad-server-config.hcl
COPY Certs/vault-ca.crt /usr/local/share/ca-certificates/vault-ca.crt
     
RUN chmod -R 755 /nomad && \
    chown -R nomad: /nomad && \
    chown -R nomad: /nomad/* && \
    chown -R nomad:ssl-cert /opt/nomad/tls && \
    update-ca-certificates && \
    cp /usr/local/share/ca-certificates/vault-ca.crt /opt/nomad/tls/vault-ca.crt

USER nomad
EXPOSE 4646 4647 4648