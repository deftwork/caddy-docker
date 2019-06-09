ARG BASEIMAGE=alpine:3.9
FROM ${BASEIMAGE}

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL mantainer="Eloy Lopez <elswork@gmail.com>" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="caddy-docker" \
    org.label-schema.description="Docker container for Caddy" \
    org.label-schema.url="https://deft.work" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/DeftWork/caddy-docker" \
    org.label-schema.vendor="Deft Work" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

RUN apk add --no-cache openssh-client git tar curl

# install caddy
ARG CAD_URL=https://caddyserver.com/download/linux/amd64?plugins=http.git\&license=personal\&telemetry=off
RUN curl --silent --show-error --fail --location \
      --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
      "${CAD_URL}" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
 && chmod 0755 /usr/bin/caddy \
 && /usr/bin/caddy -version

EXPOSE 80 443 2015
VOLUME /root/.caddy
WORKDIR /srv

COPY config/Caddyfile /etc/Caddyfile
COPY srv/index.html /srv/index.html

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--agree", "--conf", "/etc/Caddyfile", "--log", "stdout"]
