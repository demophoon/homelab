date := $(shell date +%s)
version := $(shell git rev-parse --short HEAD)-$(date)

.PHONY:build-dispatcher
build-dispatcher:
	curl -Lo ./docker/dispatcher/vault.crt https://active.vault.service.consul.demophoon.com:8200/v1/pki/ca/pem
	docker build -f docker/dispatcher/Dockerfile -t registry.internal.demophoon.com/demophoon/dispatcher:${version} -t registry.internal.demophoon.com/demophoon/dispatcher:latest docker/dispatcher

.PHONY:build-terraform
build-terraform:
	docker build -f docker/terraform/Dockerfile -t registry.internal.demophoon.com/demophoon/terraform:${version} -t registry.internal.demophoon.com/demophoon/terraform:latest docker/terraform

.PHONY:build
build: build-terraform build-dispatcher

.PHONY:push
push: build
	docker push registry.internal.demophoon.com/demophoon/terraform:${version}
	docker push registry.internal.demophoon.com/demophoon/terraform:latest

	docker push registry.internal.demophoon.com/demophoon/dispatcher:${version}
	docker push registry.internal.demophoon.com/demophoon/dispatcher:latest
