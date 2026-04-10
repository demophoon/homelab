FROM ubuntu:noble AS base

RUN apt update && apt upgrade -y
RUN apt install -y ca-certificates wget gpg coreutils nodejs npm

COPY vault.crt /usr/local/share/ca-certificates/vault.crt
RUN update-ca-certificates

RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" | tee /etc/apt/sources.list.d/hashicorp.list && \
  apt update && apt install -y nomad

RUN apt clean && rm -rf /var/lib/apt/lists/*
