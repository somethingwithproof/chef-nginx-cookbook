# Makefile for NGINX cookbook testing

.PHONY: all style spec integration-docker integration-dokken integration-suite integration-platform \
        docker-build docker-basic docker-kitchen docker-dokken docker-rspec docker-tests docker-all ci default

# Style tests
style:
	cookstyle

# ChefSpec unit tests
spec:
	bundle exec rspec

# Integration tests with Docker
integration-docker:
	KITCHEN_YAML=.kitchen.yml bundle exec kitchen test --destroy=always

# Integration tests for a specific suite
integration-suite:
	@if [ -z "$(SUITE)" ]; then \
		echo "Usage: make integration-suite SUITE=<suite-name>"; \
		exit 1; \
	fi
	bundle exec kitchen test $(SUITE) --destroy=always

# Integration tests for a specific platform
integration-platform:
	@if [ -z "$(PLATFORM)" ]; then \
		echo "Usage: make integration-platform PLATFORM=<platform-name>"; \
		exit 1; \
	fi
	bundle exec kitchen test -p $(PLATFORM) --destroy=always

# Integration tests with Dokken
integration-dokken:
	KITCHEN_YAML=.kitchen.dokken.yml bundle exec kitchen test --destroy=always

# Docker build
docker-build:
	docker build -t nginx-cookbook-test .

# Docker basic test
docker-basic: docker-build
	docker-compose run --rm test-ubuntu

# Docker Kitchen test
docker-kitchen: docker-build
	docker-compose run --rm test-kitchen

# Docker Dokken test
docker-dokken: docker-build
	docker-compose run --rm test-dokken

# Docker RSpec test
docker-rspec: docker-build
	docker-compose run --rm test-rspec

# Run all Docker-based tests
docker-tests: docker-build docker-rspec docker-basic docker-kitchen docker-dokken

# Run all tests
all: style spec integration-docker

# Run all tests on CI
ci: style spec integration-dokken

# Run all tests using Docker containers
docker-all: style spec docker-tests

# Default
default: all