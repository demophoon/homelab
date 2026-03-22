date := $(shell date +%s)
version := $(shell git rev-parse --short HEAD)-$(date)

.PHONY:build
build:
	docker build -f docker/Dockerfile -t registry.internal.demophoon.com/demophoon/terraform:${version} -t registry.internal.demophoon.com/demophoon/terraform:latest docker

.PHONY:push
push: build
	docker push registry.internal.demophoon.com/demophoon/terraform:${version}
	docker push registry.internal.demophoon.com/demophoon/terraform:latest
