DOCKER_COMPOSE_VERSION := $(shell docker-compose --version 2>/dev/null )
DOCKER_VERSION := $(shell docker-compose --version 2>/dev/null )
DOCKER_SYNC_VERSION := $(shell docker-sync --version 2>/dev/null )
PHP := 7.3
PHPMYADMIN := false
VOLUME := local
NETWORK := bridge
WEB := nginx
FILE_ADD := -f
DIRECTORY_SEPARATOR := /
DOCKER_FILE := ./docker-compose.yml
DOCKER_OVERRIDE_FILE := ./docker-compose.override.yml
DOCKER_PATH := .$(DIRECTORY_SEPARATOR).docker$(DIRECTORY_SEPARATOR)docker
DOCKER_NETWORK_PATH := $(DOCKER_PATH)$(DIRECTORY_SEPARATOR)network$(DIRECTORY_SEPARATOR)
DOCKER_VOLUME_PATH := $(DOCKER_PATH)$(DIRECTORY_SEPARATOR)volume$(DIRECTORY_SEPARATOR)
DOCKER_WEB_PATH := $(DOCKER_PATH)$(DIRECTORY_SEPARATOR)web$(DIRECTORY_SEPARATOR)
DOCKER_PHP_PATH := $(DOCKER_PATH)$(DIRECTORY_SEPARATOR)php$(DIRECTORY_SEPARATOR)
DOCKER_SEARCH_PATH := $(DOCKER_PATH)$(DIRECTORY_SEPARATOR)search$(DIRECTORY_SEPARATOR)
DOCKER_UTILITY_PATH := $(DOCKER_PATH)$(DIRECTORY_SEPARATOR)utility$(DIRECTORY_SEPARATOR)
DOCKER_SERVICES := $(FILE_ADD) $(DOCKER_FILE)
DOCKER_SERVICES += $(FILE_ADD) $(DOCKER_NETWORK_PATH)docker-network-$(NETWORK).yml
DOCKER_SERVICES += $(FILE_ADD) $(DOCKER_VOLUME_PATH)docker-volume-$(VOLUME).yml
DOCKER_SERVICES += $(FILE_ADD) $(DOCKER_WEB_PATH)docker-$(WEB).yml
DOCKER_SERVICES += $(FILE_ADD) $(DOCKER_PHP_PATH)docker-php-fpm-$(PHP).yml

ifeq '$(PHPMYADMIN)' 'true'
DOCKER_SERVICES += $(FILE_ADD) $(DOCKER_UTILITY_PATH)docker-phpmyadmin.yml
endif

ifeq '$(SEARCH)' 'true'
DOCKER_SERVICES += $(FILE_ADD) $(DOCKER_SEARCH_PATH)docker-elasticsearch.yml
endif

ifneq ("$(wildcard $(DOCKER_OVERRIDE_FILE))","")
DOCKER_SERVICES += $(FILE_ADD) $(DOCKER_OVERRIDE_FILE)
endif

# define standard colors
ifneq (,$(findstring xterm,${TERM}))
	BLACK        := $(shell tput -Txterm setaf 0)
	RED          := $(shell tput -Txterm setaf 1)
	GREEN        := $(shell tput -Txterm setaf 2)
	YELLOW       := $(shell tput -Txterm setaf 3)
	LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
	PURPLE       := $(shell tput -Txterm setaf 5)
	BLUE         := $(shell tput -Txterm setaf 6)
	WHITE        := $(shell tput -Txterm setaf 7)
	RESET := $(shell tput -Txterm sgr0)
else
	BLACK        := ""
	RED          := ""
	GREEN        := ""
	YELLOW       := ""
	LIGHTPURPLE  := ""
	PURPLE       := ""
	BLUE         := ""
	WHITE        := ""
	RESET        := ""
endif

.PHONY: config-init
config-init:
	cp ./.env.dist ./.env
	cp ./docker-sync.yml.dist ./docker-sync.yml
	cp ./.docker/config/mysql/docker.cnf.dist ./.docker/config/mysql/docker.cnf
	cp ./.docker/config/apache/default.conf.dist ./.docker/config/apache/default.conf
	cp ./.docker/config/nginx/default.conf.dist ./.docker/config/nginx/default.conf
	cp ./.docker/config/php/php.ini.dist ./.docker/config/php/php.ini
	cp ./.docker/config/ssl/certificate.cnf.dist ./.docker/config/ssl/certificate.cnf
	cp ./.docker/config/ssl/certificate.crt.dist ./.docker/config/ssl/certificate.crt
	cp ./.docker/config/ssl/certificate.key.dist ./.docker/config/ssl/certificate.key

.PHONY: config-destroy
config-destroy:
	rm -rf ./.env
	rm -rf ./docker-sync.yml
	rm -rf ./.docker/config/mysql/docker.cnf
	rm -rf ./.docker/config/apache/default.conf
	rm -rf ./.docker/config/nginx/default.conf
	rm -rf ./.docker/config/php/php.ini
	rm -rf ./.docker/config/mysql/docker.conf
	rm -rf ./.docker/config/ssl/certificate.cnf
	rm -rf ./.docker/config/ssl/certificate.crt
	rm -rf ./.docker/config/ssl/certificate.key

.PHONY: init
init: 
	@echo '${GREEN}Let Init Everything on Server Docker${RESET}'
	make config-init

.PHONY: destroy
destroy: docker-compose
	@echo '${GREEN}Let Destroy Everything on Server Docker${RESET}'
	make docker-down
	make config-destroy
	docker volume prune

.PHONY: volume-list
volume-list:
	@echo '${GREEN}Let Listing Volumes on Docker${RESET}'
	docker volume ls

.PHONY: volume-destroy
volume-destroy:
	@echo '${GREEN}Let Destroy Volume on Docker${RESET}'
	docker volume prune

.PHONY: docker-up
docker-up: docker-compose
	@echo '${GREEN}Start $(WEB) Server - PHP Version $(PHP) - Volume Type $(VOLUME) - Network Type $(NETWORK) - UTILITY $(PHPMYADMIN)${RESET}'
	docker-compose $(DOCKER_SERVICES) up --remove-orphans

.PHONY: docker-down
docker-down: docker-compose
	@echo '${GREEN}Cleanup $(WEB) Server${RESET}'
	docker-compose $(DOCKER_SERVICES) down

.PHONY: docker-sync-start
docker-sync-start:
	docker-sync start

.PHONY: docker-sync-list
docker-sync-list:
	docker-sync list

.PHONY: docker-sync-stop
docker-sync-stop:
	docker-sync stop

.PHONY: docker-sync-clean
docker-sync-clean:
	docker-sync clean

.PHONY: docker-compose
docker-compose:
ifndef DOCKER_COMPOSE_VERSION
	$(error docker-compose not found)
endif

.PHONY: docker
docker:
ifndef DOCKER_VERSION
	$(error docker not found)
endif