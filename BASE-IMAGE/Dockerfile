# Étape 1 : build de gosu statique sans vulnérabilités
FROM golang:alpine3.21 AS builder
LABEL stage="builder"
ENV CGO_ENABLED=0

RUN apk add --no-cache git
RUN git clone https://github.com/tianon/gosu.git /src/gosu

WORKDIR /src/gosu
# Compiler gosu avec CGO désactivé pour un binaire statique
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/gosu

# Étape 2 : image alpine sans vulnérabilités + création d'un utilisateur local
FROM alpine@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474
ARG LOCAL_USER
ARG USER_WORKDIR
RUN apk update && apk upgrade && \
    apk add --no-cache curl bash && \
    adduser -D -h /home/${LOCAL_USER} ${LOCAL_USER}
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu
RUN chmod +x /usr/local/bin/gosu
RUN mkdir -p ${USER_WORKDIR} && \
    mkdir -p ${USER_WORKDIR}/certs && \
    chown -R ${LOCAL_USER}:${LOCAL_USER} ${USER_WORKDIR}
USER ${LOCAL_USER}
WORKDIR /${USER_WORKDIR}
LABEL maintainer="lamboartur94@gmail.com" \
      org.opencontainers.image.source="https://github.com/LAMBOFIRSTECH/Infra-microservice/tree/main/BASE-IMAGE" \
      org.opencontainers.image.os="linux" \
      org.opencontainers.image.architecture="amd64" \
      org.opencontainers.image.created="2025-04-24" \
      org.opencontainers.image.description="alpine base image with local user and without vulnerabilities" \
      org.opencontainers.image.vendor="LAMBOFIRSTECH" \
      org.opencontainers.image.version="v1.1.1"
CMD [ "/bin/bash" ]