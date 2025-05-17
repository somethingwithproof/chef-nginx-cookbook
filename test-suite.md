# Testing the NGINX Cookbook

This cookbook includes a comprehensive testing suite to ensure quality and reliability. The tests cover unit testing with ChefSpec, linting with Cookstyle, and integration testing with Test Kitchen using both Docker and Dokken drivers.

## Prerequisites

- Ruby 2.7 or later
- Bundler
- Docker and Docker Compose (for integration tests)
- GNU Make

## Running the Tests

### Quick Start

To run all tests including unit tests, style checks, and integration tests:

```bash
make all
```

Or to run all tests using Docker (recommended):

```bash
make docker-all
```

### Individual Test Components

#### Unit Tests (ChefSpec)

```bash
make spec
```

#### Style Checks (Cookstyle)

```bash
make style
```

#### Integration Tests (Test Kitchen)

With Docker driver:

```bash
make integration-docker
```

With Dokken driver (faster):

```bash
make integration-dokken
```

Test a specific suite:

```bash
make integration-suite SUITE=default
```

Test a specific platform:

```bash
make integration-platform PLATFORM=ubuntu-22.04
```

### Docker-Based Testing

For testing within Docker containers:

```bash
# Build the Docker image
make docker-build

# Run basic tests on Ubuntu
make docker-basic

# Run Test Kitchen with Docker driver in a container
make docker-kitchen

# Run Test Kitchen with Dokken driver in a container
make docker-dokken

# Run Docker-specific tests
make docker-tests

# Run all tests in Docker (includes unit tests, style)
make docker-all
```

## Test Suites

The cookbook includes the following test suites:

1. **default** - Tests basic NGINX installation and configuration
2. **ssl** - Tests SSL/TLS configuration
3. **multi-site** - Tests configuration of multiple virtual hosts
4. **performance-tuning** - Tests performance optimization settings
5. **modules** - Tests module management

## Continuous Integration

This cookbook is set up for CI testing using GitHub Actions. See the workflow file in `.github/workflows/ci.yml` for details.

## Creating New Tests

### Adding a new ChefSpec test

1. Create a new spec file in `spec/unit/recipes/` or `spec/unit/resources/`
2. Follow the patterns in the existing spec files

### Adding a new InSpec test

1. Create a new directory under `test/integration/` for your test suite
2. Create test files with the `.rb` extension
3. Add your suite to the `.kitchen.yml` file

## Debugging Tips

- Use `kitchen login <suite-platform>` to log into a Test Kitchen instance
- Use `kitchen diagnose` to view Test Kitchen configuration
- For Docker tests, use `docker exec -it <container-id> bash` to access running containers
