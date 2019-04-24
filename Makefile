SNAME ?= arm-caddy
NAME ?= elswork/$(SNAME)
PORT ?= 2015:2015
GOARCH := $(shell uname -m)
ifeq ($(GOARCH),x86_64)
	GOARCH := amd64
else
	GOARCH := arm7
endif
GOOS ?= linux
PLUGIN ?= `cat PLUGIN`
ARCH2 ?= arm7
ONOFF ?= off
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
debug:
	docker build -t $(NAME):$(GOARCH) --build-arg VERSION=$(GOARCH)-`cat VERSION` --build-arg CAD_URL=$(URL) .
build: ## Build the container
	docker build --no-cache -t $(NAME):$(GOARCH) --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VCS_REF=`git rev-parse --short HEAD` --build-arg VERSION=$(GOARCH)-`cat VERSION` --build-arg CAD_URL=$(URL) . > ../builds/$(SNAME)_$(GOARCH)_`date +"%Y%m%d_%H%M%S"`.txt
tag: ## Tag the container
	docker tag $(NAME):$(GOARCH) $(NAME):$(GOARCH)-`cat VERSION`
push: ## Push the container
	docker push $(NAME):$(GOARCH)-`cat VERSION`
	docker push $(NAME):$(GOARCH)	
deploy:
	build tag push 	
manifest: ## Manifest the container
	docker manifest create $(NAME):`cat VERSION` $(NAME):$(GOARCH)-`cat VERSION` \
	$(NAME):$(ARCH2)-`cat VERSION`
	docker manifest push --purge $(NAME):`cat VERSION`
	docker manifest create $(NAME):latest $(NAME):$(GOARCH) $(NAME):$(ARCH2)
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
