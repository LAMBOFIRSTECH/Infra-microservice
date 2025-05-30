# ╔══════════════════════════════════════════════════╗
# ║  UI-Gravitee with no vulnerabilities             ║
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
    org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/GRAVITEE/DockerBuilderFactory/Gravitee-Ui" \
    org.opencontainers.image.os="linux" \
    org.opencontainers.image.architecture="amd64" \
    org.opencontainers.image.version="v2" \
    org.opencontainers.image.created="2025-05-30" \
    org.opencontainers.image.description="UI-Gravitee 4.0.6-1 with static gosu and no vulnerabilities" \
    org.opencontainers.image.vendor="LAMBOFIRSTECH"

# Copier gosu compilé
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu

RUN apk add --no-cache  curl shadow ca-certificates unzip openjdk21-jre  && \
    apk update && apk upgrade --no-cache && \
    adduser -D -u 1000 -g 1000 graviteeio && \
    mkdir -p /opt/gravitee-ui /opt/gravitee-ui/tls /var/log/gravitee-ui && \
    curl -L -s https://download.gravitee.io/graviteeio-apim/distributions/graviteeio-full-4.7.5.zip -o graviteeio.zip && \
    unzip graviteeio.zip -d ./temp_extraction/ && \
    mv ./temp_extraction/graviteeio-full-4.7.5/graviteeio-apim-console-ui-4.7.5/* /opt/gravitee-ui/ && \
    rm -rf ./temp_extraction && \
    rm graviteeio.zip && \
    chmod +x /usr/local/bin/gosu && \
    groupadd ssl-cert && \
    usermod -aG ssl-cert graviteeio

COPY Certs/ /opt/gravitee-ui/tls/ 
COPY init-gravitee.sh /opt/gravitee-ui/conf/init-gravitee.sh

RUN keytool -importcert \
    -noprompt \
    -trustcacerts \
    -alias vault-ca \
    -file /opt/gravitee-ui/tls/vault-ca.crt \
    -keystore $(dirname $(dirname $(readlink -f /usr/bin/java)))/lib/security/cacerts \
    -storepass changeit

WORKDIR /opt/gravitee-ui
RUN apk update && apk upgrade --no-cache \
    && chmod +x /opt/gravitee-ui/bin/gravitee \
    && chown -R graviteeio: /opt/gravitee-ui /opt/shared /var/log/gravitee-ui /opt/gravitee-ui/* \
    && chmod 600 /opt/gravitee-ui/tls/backend.pem \
    && cp /opt/gravitee-ui/tls/vault-ca.crt /usr/local/share/ca-certificates/vault-ca.crt \
    && chown -R graviteeio:ssl-cert /opt/gravitee-ui/tls \
    && update-ca-certificates \
    && chown -R graviteeio:ssl-cert /opt/gravitee-ui/tls/vault-ca.crt

# ENV PATH="/opt/gravitee-ui/bin:${PATH}"
USER graviteeio
EXPOSE 8080
CMD ["/bin/sh", "/opt/gravitee-ui/conf/init-gravitee.sh"]