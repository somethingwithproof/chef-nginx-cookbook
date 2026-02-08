# CLAUDE.md

Chef cookbook for Nginx 1.2x with security headers and module support.

## Stack
- Ruby / Chef 18.0+
- Test Kitchen + InSpec
- Dependencies: yum-epel, apt, selinux

## Lint & Test
```bash
cookstyle .
chef exec rspec
kitchen test
```

## Notes
- HTTP/2 and HTTP/3 support with dynamic module loading
- Built-in security headers (X-Frame-Options, CSP, etc.)
- Telemetry integration with Prometheus and Grafana
- Supports Brotli, ModSecurity, and cache purge modules
