# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-05-17

### Added
- Support for macOS, Windows, FreeBSD, and SUSE platforms
- Support for Oracle Linux
- kitchen-vagrant driver for local development with VirtualBox
- Policyfile support for modern dependency management

### Changed
- Updated platform support to include only non-EOL versions
- Removed yum-epel cookbook dependency in favor of direct resource usage
- Modernized helper methods and custom resources
- Updated Ruby dependency to 3.2+
- Updated Chef dependency to 18+ only

### Fixed
- Cookstyle compliance issues
- Resource idempotency in all custom resources
- Platform detection in helper methods

## [1.0.0] - 2023-10-30

### Added
- Initial release of nginx cookbook
- Comprehensive NGINX installation and configuration
- Support for multiple installation methods (package, source)
- Multiple virtual hosts support
- SSL configuration with modern defaults
- Performance tuning options
- Security hardening
- Telemetry integration (Prometheus, Grafana)
- InSpec tests and custom resources
- Multi-platform support (Ubuntu, Debian, RHEL, Amazon Linux, etc.)

## 0.1.0 (2023-10-01)

- Initial development release
