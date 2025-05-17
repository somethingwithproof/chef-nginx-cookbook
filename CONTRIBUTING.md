# Contributing to the NGINX Cookbook

We're excited that you're interested in contributing to the NGINX cookbook! This document outlines the process for contributing and guidelines to follow.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior.

## Pull Request Process

1. Fork the repository
2. Create a feature branch from the `main` branch
3. Make your changes
4. Run the tests to ensure your changes don't break existing functionality
5. Update documentation to reflect your changes if necessary
6. Submit a pull request back to the main repository

## Development Process

### Prerequisites

- Chef Workstation 21.10 or later (with Chef Infra Client 18+)
- Ruby 3.0 or later
- Docker (for integration testing with kitchen-dokken)
- VirtualBox 6.1 or later (for local testing with kitchen-vagrant)
- GNU Make
- Git 2.25 or later

### Setup Development Environment

1. Clone the repository:
   ```
   git clone https://github.com/thomasvincent/nginx_cookbook.git
   cd nginx_cookbook
   ```

2. Install Ruby using your preferred version manager (rbenv, asdf, or system Ruby):
   ```bash
   # With asdf
   asdf install ruby 3.2.3
   asdf local ruby 3.2.3
   
   # With rbenv
   rbenv install 3.2.3
   rbenv local 3.2.3
   ```

3. Install dependencies:
   ```
   gem install bundler
   bundle install
   ```

4. Initialize the Chef Policyfile:
   ```
   chef install Policyfile.rb
   ```

### Running Tests

The cookbook includes a comprehensive test suite:

```bash
# Run style checks
make style

# Run unit tests
make spec

# Run integration tests with Docker (recommended for CI)
make integration-docker

# Run integration tests with Vagrant (for full OS compatibility testing)
KITCHEN_YAML=.kitchen.vagrant.yml bundle exec kitchen test

# Run all tests
make all

# Run all tests in Docker
make docker-all
```

Read [TESTING.md](TESTING.md) for more detailed information about the testing framework.

## Coding Standards

This cookbook follows the Chef community's coding standards:

- Use Cookstyle for Ruby and Chef-specific style guidelines
- All custom resources should include `unified_mode true`
- Follow Chef Infra 18+ best practices for resource design
- Write idempotent, platform-flexible code
- Use helpers for platform-specific logic
- Ensure backward compatibility where possible
- Include thorough tests for any changes (unit tests with ChefSpec, integration tests with InSpec)
- Document all custom resources, helpers, and complex recipes

## Git Commit Guidelines

We use conventional commit messages:

- `feat:` - A new feature
- `fix:` - A bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, missing semi-colons, etc)
- `refactor:` - Code changes that neither fix bugs nor add features
- `perf:` - Performance improvements
- `test:` - Test-related changes
- `chore:` - Changes to the build process, auxiliary tools, etc.

Example: `feat: add SSL configuration options`

## Release Process

We follow [Semantic Versioning](https://semver.org/) and [Keep a Changelog](https://keepachangelog.com/) principles:

1. Update the version in `metadata.rb` according to semantic versioning:
   - MAJOR version for incompatible API changes
   - MINOR version for backwards-compatible functionality additions
   - PATCH version for backwards-compatible bug fixes

2. Update the CHANGELOG.md file with meaningful changes organized by type:
   - Added
   - Changed
   - Deprecated
   - Removed
   - Fixed
   - Security

3. Submit a PR with these changes

4. Once merged to main, maintainers will:
   - Create a new Git tag matching the version
   - Push the tag
   - The CI/CD pipeline will handle testing and release to the Chef Supermarket

## Documentation

All significant features should include documentation:

- Update the README.md with new features or changes
- Document attributes in attributes files
- Include usage examples for custom resources
- Add tests that serve as examples

## Questions?

If you have any questions or need help, please open an issue in the GitHub repository.

Thank you for contributing to the NGINX cookbook!