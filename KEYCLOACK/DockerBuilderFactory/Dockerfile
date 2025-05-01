# Étape 1 : build de gosu statique sans vulnérabilités
FROM golang:alpine3.21 AS builder
LABEL stage="builder"
ENV CGO_ENABLED=0

RUN apk add --no-cache git
RUN git clone https://github.com/tianon/gosu.git /src/gosu

WORKDIR /src/gosu
# Compiler gosu avec CGO désactivé pour un binaire statique
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/gosu

# Étape 2 : image finale Keycloak sans vulnérabilités
FROM alpine@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474
RUN apk update && apk upgrade && \
    apk add --no-cache curl openjdk17-jre bash supervisor && \
    adduser -D -u 1000 -g 1000 keycloak
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu
RUN mkdir -p /opt/keycloak && \
    mkdir -p /opt/keycloak/certs && \
    mkdir -p /opt/keycloak/data/log && \
    chown -R keycloak:keycloak /opt/keycloak

# Étape 3 : Extraction de keycloak 26.2.2 et compilation
WORKDIR /opt
COPY keycloak_start.sh /opt/keycloak/keycloak_start.sh
RUN curl -L https://github.com/keycloak/keycloak/releases/download/26.2.2/keycloak-26.2.2.tar.gz -o keycloak.tar.gz && \
    tar -xzf keycloak.tar.gz -C /opt/keycloak --strip-components=1 && \
    rm keycloak.tar.gz && \
    chown -R keycloak:keycloak /opt/keycloak/keycloak_start.sh && \
    chmod +x /opt/keycloak/keycloak_start.sh && \
    touch /run/supervisord.sock && \
    chmod 770 /run/supervisord.sock && \
    chown -R keycloak:keycloak /opt/keycloak/conf && \
    chown -R keycloak:keycloak /opt/keycloak/data && \
    touch /opt/keycloak/data/log/keycloak.log && \
    chown -R keycloak:keycloak /opt/keycloak/data/log/keycloak.log

# Étape 4 : Répertoire de travail final
WORKDIR /opt/keycloak

COPY keycloak.conf /opt/keycloak/conf/keycloak.conf
COPY fullchain.pem /opt/keycloak/certs/fullchain.pem
COPY privkey.pem /opt/keycloak/certs/privkey.pem
COPY .env /opt/keycloak/.env
COPY supervisord.conf /etc/supervisord.conf

LABEL maintainer="lamboartur94@gmail.com" \
      org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/KEYCLOACK/DockerBuilderFactory" \
      org.opencontainers.image.os="linux" \
      org.opencontainers.image.architecture="amd64" \
      org.opencontainers.image.version="v2" \
      org.opencontainers.image.created="2025-05-01" \
      org.opencontainers.image.description="Keycloak 26.2.0 with static gosu and no vulnerabilities" \
      org.opencontainers.image.vendor="LAMBOFIRSTECH"

EXPOSE 8443
CMD ["/opt/keycloak/keycloak_start.sh"]