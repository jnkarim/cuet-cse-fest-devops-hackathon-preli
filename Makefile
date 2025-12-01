# Default docker-compose files
DEV_COMPOSE=compose.development.yaml
PROD_COMPOSE=compose.production.yaml


# General Docker Services


up:
	docker-compose -f $(DEV_COMPOSE) up -d $(service)

down:
	docker-compose -f $(DEV_COMPOSE) down $(ARGS)

build:
	docker-compose -f $(DEV_COMPOSE) build $(service)

logs:
	docker-compose -f $(DEV_COMPOSE) logs -f $(service)

restart: down up

shell:
	docker-compose -f $(DEV_COMPOSE) exec $(SERVICE) sh

ps:
	docker-compose -f $(DEV_COMPOSE) ps


# Convenience Aliases (Development)


dev-up:
	make up

dev-down:
	make down

dev-build:
	make build

dev-logs:
	make logs

dev-restart:
	make restart

dev-shell:
	make shell SERVICE=backend

backend-shell:
	make shell SERVICE=backend

gateway-shell:
	make shell SERVICE=gateway

mongo-shell:
	docker-compose -f $(DEV_COMPOSE) exec mongo mongosh -u $$MONGO_INITDB_ROOT_USERNAME -p $$MONGO_INITDB_ROOT_PASSWORD

dev-ps:
	make ps


# Convenience Aliases (Production)


prod-up:
	docker-compose -f $(PROD_COMPOSE) up -d $(service)

prod-down:
	docker-compose -f $(PROD_COMPOSE) down $(ARGS)

prod-build:
	docker-compose -f $(PROD_COMPOSE) build $(service)

prod-logs:
	docker-compose -f $(PROD_COMPOSE) logs -f $(service)

prod-restart: prod-down prod-up


# Backend


backend-build:
	docker-compose -f $(DEV_COMPOSE) run --rm backend npm run build

backend-install:
	docker-compose -f $(DEV_COMPOSE) run --rm backend npm ci

backend-type-check:
	docker-compose -f $(DEV_COMPOSE) run --rm backend npm run type-check

backend-dev:
	npm run dev


# Database


db-reset:
	docker-compose -f $(DEV_COMPOSE) exec mongo mongosh -u $$MONGO_INITDB_ROOT_USERNAME -p $$MONGO_INITDB_ROOT_PASSWORD --eval "db.dropDatabase()"

db-backup:
	docker-compose -f $(DEV_COMPOSE) exec mongo mongodump --archive=/data/backup.gz --gzip


# Cleanup


clean:
	docker-compose -f $(DEV_COMPOSE) down

clean-all:
	docker-compose -f $(DEV_COMPOSE) down --volumes --rmi all

clean-volumes:
	docker volume prune -f


# Utilities


status:
	make ps

health:
	curl http://localhost:5921/api/health || echo "Service unhealthy"


# Help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'