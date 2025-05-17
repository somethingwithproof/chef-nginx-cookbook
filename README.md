# NGINX Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/nginx.svg)](https://supermarket.chef.io/cookbooks/nginx)
[![Build Status](https://img.shields.io/github/workflow/status/thomasvincent/chef-nginx-cookbook/ci)](https://github.com/thomasvincent/chef-nginx-cookbook/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A modern, advanced Chef cookbook to install and configure Nginx with comprehensive functionality.

## Requirements

### Platforms

- Ubuntu 20.04+
- Debian 11+
- CentOS Stream 8+
- Red Hat Enterprise Linux 8+
- Amazon Linux 2+
- Rocky Linux 8+
- AlmaLinux 8+
- Fedora 35+

### Chef

- Chef 18.0+

### Dependencies

- `openssl` - For SSL configurations
- `build-essential` - For source installations
- `selinux` - For SELinux configuration on RHEL-family systems
- `apt` - For repository management on Debian-based systems
- `yum-epel` - For repository management on RHEL-based systems

## Features

- Nginx installation from OS packages or source
- Support for mainline and stable branches
- Modular configuration with smart default settings
- TLS/SSL support with modern cipher configurations
- Virtual site management with template flexibility
- Advanced logging options
- Performance tuning based on system resources
- SELinux and AppArmor integration
- HTTP/2 and HTTP/3 support
- Full integration test coverage with InSpec
- Health check and monitoring integration
- Zero Downtime Deployment pattern with graceful reloads
- Ops Actions pattern for backup/restore and blue-green deployments
- Telemetry integration with Prometheus and Grafana

## Custom Resources

### nginx_install

Install Nginx web server.

```ruby
nginx_install 'default' do
  version '1.24.0'
  install_method 'package'
  action :install
end
```

Properties:
- `version` - Nginx version to install
- `install_method` - Installation method (package, source)
- `package_name` - Package name, if using package installation
- `source_url` - Source URL, if using source installation
- `checksum` - Checksum for source package

### nginx_config

Create Nginx configuration snippets.

```ruby
nginx_config 'security' do
  source 'security.conf.erb'
  cookbook 'nginx'
  notifies :reload, 'nginx_service[default]'
  action :create
end
```

Properties:
- `source` - Template source
- `cookbook` - Cookbook containing the template
- `variables` - Variables to pass to the template
- `config_name` - Name of the configuration file (defaults to resource name)

### nginx_module

Enable or disable Nginx modules.

```ruby
nginx_module 'ssl' do
  action :enable
end

nginx_module 'status' do
  configuration <<~EOL
    location /nginx_status {
      stub_status on;
      allow 127.0.0.1;
      deny all;
    }
  EOL
  action :enable
end
```

Properties:
- `module_name` - Module name (defaults to resource name)
- `configuration` - Configuration for the module
- `install_package` - Whether to install package for the module

### nginx_site

Configure Nginx sites/virtual hosts.

```ruby
nginx_site 'example.com' do
  port 80
  root '/var/www/example.com'
  action :create
end

nginx_site 'secure.example.com' do
  port 443
  root '/var/www/secure.example.com'
  ssl_enabled true
  ssl_cert '/etc/ssl/certs/example.com.crt'
  ssl_key '/etc/ssl/private/example.com.key'
  action :create
end
```

Properties:
- `domain` - Domain name (defaults to resource name)
- `port` - Port to listen on
- `root` - Document root directory
- `server_name` - Server names to respond to
- `error_log` - Error log path
- `access_log` - Access log path
- `ssl_enabled` - Whether to enable SSL
- `ssl_cert` - SSL certificate path
- `ssl_key` - SSL key path
- `ssl_chain` - SSL chain path
- `redirect_http_to_https` - Whether to redirect HTTP to HTTPS
- `custom_directives` - Custom Nginx directives to include

### nginx_service

Manage the Nginx service.

```ruby
nginx_service 'default' do
  action [:enable, :start]
end
```

Properties:
- `service_name` - Service name
- `restart_command` - Command to restart the service
- `reload_command` - Command to reload the service
- `supports` - Service supports hash

## Attributes

See the [attributes file](attributes/default.rb) for default values.

### General

- `node['nginx']['version']` - Nginx version
- `node['nginx']['install_method']` - Installation method
- `node['nginx']['service_name']` - Service name
- `node['nginx']['conf_dir']` - Configuration directory
- `node['nginx']['sites_dir']` - Sites directory

### Paths

- `node['nginx']['log_dir']` - Log directory
- `node['nginx']['pid_file']` - PID file path
- `node['nginx']['binary']` - Path to nginx binary

### Security

- `node['nginx']['security']['server_tokens']` - Whether to display server tokens
- `node['nginx']['security']['server_signature']` - Whether to display server signature
- `node['nginx']['security']['hide_headers']` - Headers to hide
- `node['nginx']['security']['client_body_buffer_size']` - Client body buffer size
- `node['nginx']['security']['client_max_body_size']` - Maximum client body size

### Performance

- `node['nginx']['performance']['worker_processes']` - Number of worker processes
- `node['nginx']['performance']['worker_connections']` - Number of worker connections
- `node['nginx']['performance']['open_file_cache']` - Open file cache settings
- `node['nginx']['performance']['keepalive_timeout']` - Keepalive timeout
- `node['nginx']['performance']['sendfile']` - Use sendfile
- `node['nginx']['performance']['tcp_nopush']` - Use TCP_NOPUSH
- `node['nginx']['performance']['tcp_nodelay']` - Use TCP_NODELAY

### Telemetry

- `node['nginx']['telemetry']['enabled']` - Enable telemetry functionality
- `node['nginx']['telemetry']['prometheus']['enabled']` - Enable Prometheus exporter
- `node['nginx']['telemetry']['prometheus']['metrics']` - Metrics to collect
- `node['nginx']['telemetry']['prometheus']['allow_ips']` - IPs allowed to access metrics
- `node['nginx']['telemetry']['grafana']['enabled']` - Enable Grafana dashboard
- `node['nginx']['telemetry']['grafana']['url']` - Grafana URL
- `node['nginx']['telemetry']['grafana']['datasource']` - Prometheus datasource name
- `node['nginx']['telemetry']['grafana']['api_key']` - Grafana API key

## Recipes

- `default.rb` - Calls other recipes
- `install.rb` - Installs Nginx
- `configure.rb` - Basic configuration
- `service.rb` - Sets up service
- `sites.rb` - Configures sites from attributes
- `security.rb` - Applies security hardening
- `telemetry.rb` - Configures Prometheus and Grafana integration

## Usage

### Basic

Include `nginx` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[nginx::default]"
  ]
}
```

### Advanced

Configure attributes in a role or wrapper cookbook:

```ruby
default_attributes = {
  'nginx' => {
    'install_method' => 'package',
    'performance' => {
      'worker_processes' => 'auto',
      'worker_connections' => 1024
    },
    'telemetry' => {
      'enabled' => true,
      'prometheus' => {
        'enabled' => true,
        'metrics' => ['connections', 'requests', 'http']
      },
      'grafana' => {
        'enabled' => true,
        'url' => 'http://grafana.example.com:3000',
        'datasource' => 'Prometheus'
      }
    },
    'sites' => {
      'example.com' => {
        'port' => 80,
        'root' => '/var/www/example.com'
      },
      'secure.example.com' => {
        'port' => 443,
        'root' => '/var/www/secure.example.com',
        'ssl_enabled' => true,
        'ssl_cert' => '/etc/ssl/certs/secure.example.com.crt',
        'ssl_key' => '/etc/ssl/private/secure.example.com.key'
      }
    }
  }
}
```

## Testing

This cookbook uses:

- ChefSpec for unit testing
- InSpec for integration testing
- Test Kitchen for platform testing
- GitHub Actions for CI/CD

```bash
# Run all tests
delivery local all

# Run unit tests
chef exec rspec

# Run integration tests
kitchen test
```

## License

Apache 2.0

## Author

Thomas Vincent (<thomasvincent@example.com>)