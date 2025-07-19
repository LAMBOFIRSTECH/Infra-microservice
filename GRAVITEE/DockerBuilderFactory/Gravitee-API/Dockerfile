# ╔══════════════════════════════════════════════════╗
# ║# Api-Manager for Gravitee with no vulnerabilities║
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

# Étape 2 : image finale Gravitee api sans vulnérabilités
FROM alpine@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474

LABEL maintainer="lamboartur94@gmail.com" \
    org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/GRAVITEE/DockerBuilderFactory/Gravitee-API" \
    org.opencontainers.image.os="linux" \
    org.opencontainers.image.architecture="amd64" \
    org.opencontainers.image.version="v2" \
    org.opencontainers.image.created="2025-05-28" \
    org.opencontainers.image.description="Gravitee API 4.7.5 with static gosu and no vulnerabilities" \
    org.opencontainers.image.vendor="LAMBOFIRSTECH"

# Copier gosu compilé
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu

RUN apk add --no-cache  curl shadow ca-certificates unzip openjdk21-jre  && \
    apk update && apk upgrade --no-cache && \
    adduser -D -u 1000 -g 1000 graviteeio && \
    mkdir -p /opt/gravitee-mgnt /opt/gravitee-mgnt/tls /var/log/gravitee-mgnt /opt/shared && \
    curl -L -s https://download.gravitee.io/graviteeio-apim/distributions/graviteeio-full-4.7.5.zip -o graviteeio.zip && \
    unzip graviteeio.zip -d ./temp_extraction/ && \
    mv ./temp_extraction/graviteeio-full-4.7.5/graviteeio-apim-rest-api-4.7.5/* /opt/gravitee-mgnt/ && \
    rm -rf ./temp_extraction && \
    rm graviteeio.zip && \
    chmod +x /usr/local/bin/gosu && \
    groupadd ssl-cert && \
    usermod -aG ssl-cert graviteeio

COPY Certs/ /opt/gravitee-mgnt/tls/
COPY Configs/ /opt/gravitee-mgnt/config/ 
COPY init-gravitee.sh /opt/gravitee-mgnt/conf/init-gravitee.sh

WORKDIR /opt/gravitee-mgnt
RUN apk update && apk upgrade --no-cache \
    && chmod o+r /etc/ssl/certs/java/cacerts \
    && chmod +x /opt/gravitee-mgnt/bin/gravitee \
    && mkdir -p /opt/gravitee-mgnt/plugins/disabled \
    && chown -R graviteeio: /opt/gravitee-mgnt /opt/shared /var/log/gravitee-mgnt /opt/gravitee-mgnt/* /opt/gravitee-mgnt/config /opt/gravitee-mgnt/plugins/disabled \
    && chmod 777 /var/log/gravitee-mgnt \
    && chmod 600 /opt/gravitee-mgnt/tls/backend.pem \
    && cp /opt/gravitee-mgnt/tls/vault-ca.crt /usr/local/share/ca-certificates/vault-ca.crt \
    && chown -R graviteeio:ssl-cert /opt/gravitee-mgnt/tls \
    && update-ca-certificates \
    && chown -R graviteeio:ssl-cert /opt/gravitee-mgnt/tls/vault-ca.crt /etc/ssl/certs/java/cacerts /usr/lib/jvm/java-21-openjdk/lib/security/cacerts \
    && chmod 644 /usr/lib/jvm/java-21-openjdk/lib/security/cacerts \
    && mv /opt/gravitee-mgnt/plugins/gravitee-secret-provider-kubernetes-2.0.0.zip /opt/gravitee-mgnt/plugins/disabled/


ENV PATH="/opt/gravitee-mgnt/bin:${PATH}"
USER graviteeio
EXPOSE 8083
CMD ["/bin/sh", "/opt/gravitee-mgnt/conf/init-gravitee.sh"]