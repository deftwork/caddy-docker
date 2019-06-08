SNAME ?= arm-caddy
NAME ?= elswork/$(SNAME)
VER ?= `cat VERSION`
BASE ?= 3.9
BASENAME ?= alpine:$(BASE)
PORT ?= 2015:2015
GOOS ?= linux
PLUGIN ?= `cat PLUGIN`
ONOFF ?= off
ARCH2 ?= arm7
ARCH3 ?= arm64
GOARCH := $(shell uname -m)
ifeq ($(GOARCH),x86_64)
	GOARCH := amd64
endif
ifeq ($(GOARCH),armv7l)
	GOARCH := arm7
endif
ifeq ($(GOARCH),aarch64)
	GOARCH := arm64
endif

URL ?= https://caddyserver.com/download/$(GOOS)/$(GOARCH)?plugins=$(PLUGIN)\&license=personal\&telemetry=$(ONOFF)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
# Build the container
debug: ## Build the container
	docker build -t $(NAME):$(GOARCH) \
	--build-arg CAD_URL=$(URL) \
	--build-arg BASEIMAGE=$(BASENAME) \
	--build-arg VERSION=$(GOARCH)_$(VER) .
build: ## Build the container
	docker build --no-cache -t $(NAME):$(GOARCH) \
	--build-arg CAD_URL=$(URL) \
	--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	--build-arg VCS_REF=`git rev-parse --short HEAD` \
	--build-arg BASEIMAGE=$(BASENAME) \
	--build-arg VERSION=$(GOARCH)_$(VER) \
	. > ../builds/$(SNAME)_$(GOARCH)_$(VER)_`date +"%Y%m%d_%H%M%S"`.txt
tag: ## Tag the container
	docker tag $(NAME):$(GOARCH) $(NAME):$(GOARCH)_$(VER)
push: ## Push the container
	docker push $(NAME):$(GOARCH)_$(VER)
	docker push $(NAME):$(GOARCH)	
deploy: ## Build Tag and Push the container
	build tag push 	
manifest: ## Create an push manifest
	docker manifest create $(NAME):$(VER) \
	$(NAME):$(GOARCH)_$(VER) \
	$(NAME):$(ARCH2)_$(VER) \
	$(NAME):$(ARCH3)_$(VER)
	docker manifest push --purge $(NAME):$(VER)
	docker manifest create $(NAME):latest $(NAME):$(GOARCH) \
	$(NAME):$(ARCH2) \
	$(NAME):$(ARCH3)
	docker manifest push --purge $(NAME):latest
run: ## Run the container
	docker run -d -p $(PORT) --name my_$(SNAME) $(NAME):$(GOARCH)
start: ## Start the container
	docker start my_$(SNAME)
stop: ## Stop the container
	docker stop my_$(SNAME)
delete: ## Delete the container
	docker rm my_$(SNAME)
publish: ## Publish Deft.Work
	docker run -d -p 80:80 -p 443:443 \
	-v /home/pirate/docker/www:/srv \
	-v /home/pirate/docker/Caddyfile/https:/etc/Caddyfile \
	-v /home/pirate/docker/.caddy:/root/.caddy --restart=unless-stopped $(NAME):$(GOARCH)
