# Copyright (c) Cloud Crew
# Licensed under the MIT License

FROM ghcr.io/alpine:3.19

LABEL org.opencontainers.image.authors="Cloud Crew" \
    org.opencontainers.image.url="https://github.com/cloud-crew/opsgenie-send-alert" \
    org.opencontainers.image.source="https://github.com/cloud-crew/opsgenie-send-alert" \
    org.opencontainers.image.documentation="https://github.com/cloud-crew/opsgenie-send-alert" \
    org.opencontainers.image.licenses="MIT"

RUN apk --update add bash curl jq

COPY ["entrypoint.sh", "LICENSE", "/"]
ENTRYPOINT ["/entrypoint.sh"]
