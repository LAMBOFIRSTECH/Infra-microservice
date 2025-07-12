# ╔══════════════════════════════════════════════════╗
# ║ Nexus sonatype repository nexus-3.82.0          ║
# ║ - Base: golang:1.24.2-alpine3.21                 ║
# ╚══════════════════════════════════════════════════╝

########## Étape 1 : Image finale sécurisée ##########
FROM sonatype/nexus3:3.82.0-java17-alpine 
USER root
ARG  NEXUS_PASS
# Installer les outils nécessaires (curl, shadow, etc.)
RUN apk add --no-cache shadow ca-certificates && \
    echo "nexus:${NEXUS_PASS}" | chpasswd && \
    mkdir -p /opt/sonatype/tls && \
    chown -R nexus: /opt/sonatype && \
    groupadd ssl-cert && \
    usermod -aG ssl-cert nexus && \
    apk del shadow curl && \
    rm -rf /var/cache/apk/* /tmp/* /root/.cache

WORKDIR /opt/sonatype

LABEL maintainer="lamboartur94@gmail.com" \
        org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/NEXUS/DockerBuilderFactory" \
        org.opencontainers.image.os="linux" \
        org.opencontainers.image.architecture="amd64" \
        org.opencontainers.image.version="v2" \
        org.opencontainers.image.created="2025-07-12" \
        org.opencontainers.image.description="Nexus sonatype repository with no vulnerabilities" \
        org.opencontainers.image.vendor="LAMBOFIRSTECH"

COPY Certs/ /opt/sonatype/tls/
COPY nexus.conf /etc/security/limits.d/nexus.conf

RUN chmod -R 755 /opt/sonatype && \
    chmod 600 /opt/sonatype/tls/backend.key && \
    chown -R nexus:ssl-cert /opt/sonatype/tls

RUN keytool -importcert \
    -noprompt \
    -trustcacerts \
    -alias vault-ca \
    -file /opt/sonatype/tls/vault-ca.crt \
    -keystore $(dirname $(dirname $(readlink -f /usr/bin/java)))/lib/security/cacerts \
    -storepass changeit

USER nexus

EXPOSE 8081