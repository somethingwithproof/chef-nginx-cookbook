# Testing the NGINX Cookbook

This document provides a quick reference for testing the NGINX cookbook. For detailed information, see the [test-suite.md](test-suite.md) file.

## Quick Reference

### Prerequisites

- Ruby 2.7+
- Bundler
- Docker and Docker Compose (for container-based tests)
- GNU Make

### Test Commands

```bash
# Install dependencies
bundle install

# Run all tests (style, unit, integration)
make all

# Run just unit tests (fast)
make spec

# Run just style checks (fast)
make style

# Run Docker-based tests (reliable)
make docker-all

# Run tests for a specific suite
make integration-suite SUITE=default

# Run tests for a specific platform
make integration-platform PLATFORM=ubuntu-22.04
```

## Test Organization

The cookbook includes a comprehensive test suite with:

- **Unit tests**: ChefSpec tests in `spec/`
- **Integration tests**: InSpec tests in `test/integration/`
- **Test Kitchen**: Platform-specific testing
  - Docker driver for local development
  - Dokken driver for CI

## CI/CD

The CI/CD pipeline uses GitHub Actions to run the test suite on every pull request and merge to the main branch. The configuration is in `.github/workflows/ci.yml`.

## Development Workflow

1. Make your changes
2. Run unit tests and linting: `make spec style`
3. Run integration tests: `make integration-docker`
4. If all tests pass, submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details on the contribution process.