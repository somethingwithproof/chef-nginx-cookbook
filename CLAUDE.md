# chef-nginx-cookbook

## Purpose
Modern Chef cookbook to install and configure NGINX with security headers, module support, and comprehensive configuration.

## Stack
- Chef 18+ / Ruby
- ChefSpec (unit), Test Kitchen with kitchen-dokken (integration)
- Policyfile for dependency management
- Depends on `yum-epel`, `apt`, `selinux`

## Build / Test
```bash
bundle install
bundle exec cookstyle          # Lint
bundle exec rspec              # ChefSpec unit tests
bundle exec kitchen test       # Integration tests (Docker)
```

## Standards
- Unified mode for custom resources
- Guard properties on all `execute` resources
- ChefSpec tests in `spec/`, InSpec tests in `test/`
- Cookstyle clean
- Custom resources in `resources/`
