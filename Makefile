APP_NAME=student-app
ENV_FILE=.env
VERSION ?= $(shell ./gradlew -q printVersion)
IMAGE_NAME ?= student-app
IMAGE_TAG ?= $(IMAGE_NAME):$(VERSION)

JAR_FILE=build/libs/$(APP_NAME)-$(VERSION).jar

.PHONY: help build run-local test clean db-up db-down docker-build docker-run

help:
	@echo "Available commands:"
	@echo "  make build          - Build the application (Gradle)"
	@echo "  make run-local      - Run the app locally with java -jar (non-docker)"
	@echo "  make test           - Run unit tests"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make db-up          - Start local Postgres in Docker"
	@echo "  make db-down        - Stop local Postgres"
	@echo "  make docker-build   - Build Docker image $(IMAGE_TAG)"
	@echo "  make docker-run     - Run Docker container from $(IMAGE_TAG)"

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
	@set -a && source $(ENV_FILE) && set +a && \
	docker run --name student-db \
		-e POSTGRES_USER="$$DB_USERNAME" \
		-e POSTGRES_PASSWORD="$$DB_PASSWORD" \
		-e POSTGRES_DB="$$DB_NAME" \
		-p $$DB_PORT:$$DB_PORT \
		-d postgres:15

db-down:
	@if [ ! -f $(ENV_FILE) ]; then echo "Missing .env file. Create one first."; exit 1; fi
	@set -a && source $(ENV_FILE) && set +a && \
	docker stop "$$DB_NAME" || true
	docker rm "$$DB_NAME" || true

docker-build:
	./gradlew clean bootJar
	docker build -t $(IMAGE_TAG) .

docker-run:
	@if [ ! -f $(ENV_FILE) ]; then echo "Missing .env file. Create one first."; exit 1; fi
	@set -a && source $(ENV_FILE) && set +a && \
	docker run --rm \
	  -p $$SERVER_PORT:$$SERVER_PORT \
	  -e DB_URL="$$DB_URL" \
	  -e DB_USERNAME="$$DB_USERNAME" \
	  -e DB_PASSWORD="$$DB_PASSWORD" \
	  -e SERVER_PORT="$$SERVER_PORT" \
	  $(IMAGE_TAG)