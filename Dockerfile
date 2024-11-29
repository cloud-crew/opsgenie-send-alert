# Copyright (c) Cloud Crew
# Licensed under the MIT License

FROM ghcr.io/linuxcontainers/alpine:3.20

LABEL org.opencontainers.image.authors="Cloud Crew" \
    org.opencontainers.image.url="https://github.com/cloud-crew/opsgenie-send-alert" \
    org.opencontainers.image.source="https://github.com/cloud-crew/opsgenie-send-alert" \
    org.opencontainers.image.documentation="https://github.com/cloud-crew/opsgenie-send-alert" \
    org.opencontainers.image.licenses="MIT"

RUN apk --update add bash curl jq

# Copiar o script e garantir permissões de execução
COPY ["entrypoint.sh", "LICENSE", "/"]
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
