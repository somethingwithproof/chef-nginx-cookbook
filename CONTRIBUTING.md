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

- Chef Workstation or ChefDK (Chef Development Kit)
- Ruby 2.7 or later
- Docker (for integration testing)
- GNU Make

### Setup Development Environment

1. Clone the repository:
   ```
   git clone https://github.com/thomasvincent/nginx_cookbook.git
   cd nginx_cookbook
   ```

2. Install dependencies:
   ```
   bundle install
   ```

### Running Tests

The cookbook includes a comprehensive test suite:

```bash
# Run all tests
make all

# Or run tests in Docker (recommended)
make docker-all
```

Read [TESTING.md](TESTING.md) for more detailed information about the testing framework.

## Coding Standards

This cookbook follows the Chef community's coding standards:

- Use ChefStyle for Ruby style guidelines
- Follow Chef best practices for resource design
- Write clear, maintainable code
- Include thorough tests for any changes

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

1. Update the version in `metadata.rb` according to semantic versioning
2. Update the CHANGELOG.md file
3. Create a new Git tag matching the version
4. Push the tag
5. The CI/CD pipeline will handle testing and release

## Documentation

All significant features should include documentation:

- Update the README.md with new features or changes
- Document attributes in attributes files
- Include usage examples for custom resources
- Add tests that serve as examples

## Questions?

If you have any questions or need help, please open an issue in the GitHub repository.

Thank you for contributing to the NGINX cookbook!