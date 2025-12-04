APP_NAME=student-app
VERSION := $(shell ./gradlew -q printVersion)
ENV_FILE=.env
JAR_FILE=build/libs/$(APP_NAME)-$(VERSION).jar

.PHONY: help build run test clean

help:
	@echo "Available commands:"
	@echo "  make build        - Build the application"
	@echo "  make run          - Run the application locally"
	@echo "  make test         - Run all unit tests"
	@echo "  make clean        - Clean build artifacts"

build:
	./gradlew clean build

run: build
	@if [ ! -f $(ENV_FILE) ]; then echo "Missing .env file. Create one first."; exit 1; fi
	@set -a && source $(ENV_FILE) && set +a && \
	java -jar $(JAR_FILE)

test:
	./gradlew test

clean:
	./gradlew clean
