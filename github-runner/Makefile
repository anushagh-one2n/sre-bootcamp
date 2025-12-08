ENV_FILE=.env
COMPOSE= docker compose -f docker-compose.runner.yml

.PHONY: help docker-run docker-down

help:
	@echo "Available commands:"
	@echo "  make docker-run     - Start self hosted github runner"
	@echo "  make docker-down    - Stop runner"


docker-run:
	$(COMPOSE) up --build -d

docker-down:
	$(COMPOSE) down
