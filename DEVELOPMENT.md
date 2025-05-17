# Development Guide for NGINX Cookbook

This guide provides information for developers working on the NGINX cookbook.

## Development Environment Setup

### Prerequisites

- Chef Workstation or ChefDK (Chef Development Kit)
- Ruby 2.7 or later
- Docker and Docker Compose (for container-based testing)
- GNU Make

### Setting Up

1. Clone the repository:
   ```bash
   git clone https://github.com/thomasvincent/nginx_cookbook.git
   cd nginx_cookbook
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

## Development Workflow

1. Create a feature branch from `main`
2. Implement your changes
3. Write/update tests
4. Ensure all tests pass (`make all` or `make docker-all`)
5. Submit a pull request

## Cookbook Structure

```
nginx_cookbook/
├── attributes/           # Attribute files
├── libraries/            # Helper libraries
├── recipes/              # Core recipes
├── resources/            # Custom resources
├── templates/            # ERB templates
├── test/
│   └── integration/      # InSpec tests
├── spec/                 # ChefSpec tests
└── compliance/           # InSpec compliance profiles
```

## Key Components

### Custom Resources

The cookbook uses modern Chef custom resources for its core functionality:

- `nginx_install` - Handles installation of NGINX
- `nginx_config` - Manages configuration files
- `nginx_site` - Creates and manages virtual hosts
- `nginx_service` - Manages the NGINX service
- `nginx_module` - Enables and configures NGINX modules

### Attributes

Attributes are organized into logical files:

- `default.rb` - Core settings
- `security.rb` - Security-related settings
- `performance.rb` - Performance optimization settings
- `telemetry.rb` - Monitoring and telemetry settings
- `logrotate.rb` - Log rotation settings

### Templates

The cookbook provides templates for various configuration files:

- `nginx.conf.erb` - Main configuration
- `site.conf.erb` - Virtual host configuration
- `security.conf.erb` - Security settings
- `ssl.conf.erb` - SSL/TLS configuration
- `status.conf.erb` - Status monitoring configuration

## Testing

See [TESTING.md](TESTING.md) for detailed testing information.

## Releasing

1. Update the version in `metadata.rb` following semantic versioning
2. Update the `CHANGELOG.md` with the changes
3. Commit the changes with a message like "Bump version to x.y.z"
4. Create a tag for the version: `git tag x.y.z`
5. Push the changes and tag: `git push origin main --tags`

## Documentation

Always update documentation when making changes:

- Update README.md for user-facing changes
- Update attributes files with proper descriptions
- Add examples for new functionality
- Update CHANGELOG.md with changes

## Coding Standards

- Follow the Chef style guide
- Use Cookstyle for style compliance
- Write clear, well-documented code
- Include comprehensive tests for all changes

See [CONTRIBUTING.md](CONTRIBUTING.md) for more details on contribution guidelines.