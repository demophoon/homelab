FROM alpine:latest AS base

COPY --from=hashicorp/terraform:1.13 /bin/terraform /bin/
COPY --from=hashicorp/nomad:1.9.7 /bin/nomad /bin/

COPY ./entrypoint.sh /entrypoint.sh

RUN apk add --no-cache git bash
ENTRYPOINT ["/entrypoint.sh"]
