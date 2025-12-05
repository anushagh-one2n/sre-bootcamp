APP_NAME=student-app
ENV_FILE=.env
VERSION ?= $(shell ./gradlew -q printVersion)
IMAGE_NAME ?= student-app
IMAGE_TAG ?= $(IMAGE_NAME):$(VERSION)
JAR_FILE=build/libs/$(APP_NAME)-$(VERSION).jar

COMPOSE = docker compose

.PHONY: help build run-local test clean db-up migrate docker-build docker-run docker-down lint-check docker-push

help:
	@echo "Available commands:"
	@echo "  make build          - Build the app with Gradle"
	@echo "  make run-local      - Run the app locally with java -jar (non-docker)"
	@echo "  make test           - Run unit tests"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make db-up          - Start Postgres via docker-compose"
	@echo "  make migrate        - Run Flyway DB migrations via docker-compose"
	@echo "  make docker-build   - Build REST API Docker image"
	@echo "  make docker-run     - Start DB, run migrations, and start API"
	@echo "  make docker-down    - Stop all docker-compose services"
	@echo "  make lint-check     - Run code formatting / linting (Spotless) check"
	@echo "  make docker-push    - Push Docker image to registry"

build:
	./gradlew clean build

run-local: build
	@if [ ! -f $(ENV_FILE) ]; then echo "Missing .env file. Create one first."; exit 1; fi
	@set -a && source $(ENV_FILE) && set +a && \
	java -jar $(JAR_FILE)

test:
	./gradlew test

clean:
	./gradlew clean

db-up:
	@if [ ! -f $(ENV_FILE) ]; then echo "Missing .env file. Create one first."; exit 1; fi
	$(COMPOSE) up -d postgres

migrate:
	@if [ ! -f $(ENV_FILE) ]; then echo "Missing .env file. Create one first."; exit 1; fi
	$(COMPOSE) run --rm flyway

docker-build:
	@if [ ! -f $(ENV_FILE) ]; then echo "Missing .env file. Create one first."; exit 1; fi
	VERSION=$(VERSION) $(COMPOSE) build api

docker-run: db-up migrate docker-build
	VERSION=$(VERSION) $(COMPOSE) up -d api

docker-down:
	$(COMPOSE) down

lint-check:
	./gradlew spotlessCheck

docker-push:
	@if [ -z "$(DOCKER_REPO)" ]; then echo "DOCKER_REPO must be set (e.g. myuser/student-app)"; exit 1; fi
	docker tag $(IMAGE_TAG) $(DOCKER_REPO):$(VERSION)
	docker push $(DOCKER_REPO):$(VERSION)
