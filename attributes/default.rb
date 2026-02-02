# frozen_string_literal: true

#
# Cookbook:: nginx
# Attributes:: default
#
# Copyright:: 2023-2025, Thomas Vincent
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Installation attributes
default['nginx']['install_method'] = 'package' # 'package' or 'source'
default['nginx']['version'] = '1.24.0'
default['nginx']['binary'] = '/usr/sbin/nginx'

# Package-specific attributes
case node['platform_family']
when 'rhel', 'fedora', 'amazon'
  default['nginx']['package_name'] = 'nginx'
  default['nginx']['service_name'] = 'nginx'
  default['nginx']['conf_dir'] = '/etc/nginx'
  default['nginx']['sites_dir'] = '/etc/nginx/conf.d'
  default['nginx']['user'] = 'nginx'
  default['nginx']['group'] = 'nginx'
  default['nginx']['pid_file'] = '/var/run/nginx.pid'
  default['nginx']['log_dir'] = '/var/log/nginx'
  default['nginx']['error_log'] = '/var/log/nginx/error.log'
  default['nginx']['access_log'] = '/var/log/nginx/access.log'
when 'debian'
  default['nginx']['package_name'] = 'nginx-core'
  default['nginx']['service_name'] = 'nginx'
  default['nginx']['conf_dir'] = '/etc/nginx'
  default['nginx']['sites_dir'] = '/etc/nginx/sites-enabled'
  default['nginx']['sites_available_dir'] = '/etc/nginx/sites-available'
  default['nginx']['user'] = 'www-data'
  default['nginx']['group'] = 'www-data'
  default['nginx']['pid_file'] = '/var/run/nginx.pid'
  default['nginx']['log_dir'] = '/var/log/nginx'
  default['nginx']['error_log'] = '/var/log/nginx/error.log'
  default['nginx']['access_log'] = '/var/log/nginx/access.log'
when 'freebsd'
  default['nginx']['package_name'] = 'nginx'
  default['nginx']['service_name'] = 'nginx'
  default['nginx']['conf_dir'] = '/usr/local/etc/nginx'
  default['nginx']['sites_dir'] = '/usr/local/etc/nginx/sites-enabled'
  default['nginx']['sites_available_dir'] = '/usr/local/etc/nginx/sites-available'
  default['nginx']['user'] = 'www'
  default['nginx']['group'] = 'www'
  default['nginx']['binary'] = '/usr/local/sbin/nginx'
  default['nginx']['pid_file'] = '/var/run/nginx.pid'
  default['nginx']['log_dir'] = '/var/log/nginx'
  default['nginx']['error_log'] = '/var/log/nginx/error.log'
  default['nginx']['access_log'] = '/var/log/nginx/access.log'
when 'mac_os_x'
  default['nginx']['package_name'] = 'nginx'
  default['nginx']['service_name'] = 'nginx'
  default['nginx']['conf_dir'] = '/opt/homebrew/etc/nginx'
  default['nginx']['sites_dir'] = '/opt/homebrew/etc/nginx/servers'
  default['nginx']['sites_available_dir'] = '/opt/homebrew/etc/nginx/servers'
  default['nginx']['user'] = '_www'
  default['nginx']['group'] = '_www'
  default['nginx']['binary'] = '/opt/homebrew/bin/nginx'
  default['nginx']['pid_file'] = '/opt/homebrew/var/run/nginx.pid'
  default['nginx']['log_dir'] = '/opt/homebrew/var/log/nginx'
  default['nginx']['error_log'] = '/opt/homebrew/var/log/nginx/error.log'
  default['nginx']['access_log'] = '/opt/homebrew/var/log/nginx/access.log'
end

# Source installation attributes
default['nginx']['source']['url'] = "https://nginx.org/download/nginx-#{node['nginx']['version']}.tar.gz"
default['nginx']['source']['checksum'] = nil # Auto-generated
default['nginx']['source']['prefix'] = '/usr/local/nginx'
default['nginx']['source']['configure_options'] = %w(
  --with-http_ssl_module
  --with-http_v2_module
  --with-http_realip_module
  --with-http_addition_module
  --with-http_sub_module
  --with-http_dav_module
  --with-http_flv_module
  --with-http_mp4_module
  --with-http_gunzip_module
  --with-http_gzip_static_module
  --with-http_random_index_module
  --with-http_secure_link_module
  --with-http_stub_status_module
  --with-mail
  --with-mail_ssl_module
  --with-file-aio
  --with-threads
)
default['nginx']['source']['dependencies'] = case node['platform_family']
                                             when 'rhel', 'fedora', 'amazon'
                                               %w(
                                                 openssl-devel
                                                 pcre-devel
                                                 zlib-devel
                                                 libxml2-devel
                                                 libxslt-devel
                                                 gd-devel
                                                 perl-devel
                                                 perl-ExtUtils-Embed
                                                 gperftools-devel
                                               )
                                             when 'debian'
                                               %w(
                                                 libssl-dev
                                                 libpcre3-dev
                                                 zlib1g-dev
                                                 libxml2-dev
                                                 libxslt1-dev
                                                 libgd-dev
                                                 libperl-dev
                                                 libgeoip-dev
                                                 libgoogle-perftools-dev
                                               )
                                             when 'freebsd'
                                               %w(
                                                 pcre
                                                 libxml2
                                                 libxslt
                                                 libgd
                                                 perl5
                                               )
                                             when 'mac_os_x'
                                               %w(
                                                 pcre
                                                 openssl
                                                 libxml2
                                                 libxslt
                                               )
                                             else
                                               []
                                             end

# Performance tuning
cpu_count = node['cpu'] ? node['cpu']['total'].to_i : 2
default['nginx']['performance']['worker_processes'] = cpu_count
default['nginx']['performance']['worker_connections'] = 1024
default['nginx']['performance']['worker_rlimit_nofile'] = 4096
default['nginx']['performance']['worker_shutdown_timeout'] = '30s'
default['nginx']['performance']['worker_cpu_affinity'] = 'auto'
default['nginx']['performance']['multi_accept'] = 'on'
default['nginx']['performance']['open_file_cache_max'] = 1000
default['nginx']['performance']['open_file_cache_inactive'] = '20s'
default['nginx']['performance']['open_file_cache_valid'] = '30s'
default['nginx']['performance']['open_file_cache_min_uses'] = 2
default['nginx']['performance']['open_file_cache_errors'] = 'on'
default['nginx']['performance']['sendfile'] = 'on'
default['nginx']['performance']['tcp_nopush'] = 'on'
default['nginx']['performance']['tcp_nodelay'] = 'on'
default['nginx']['performance']['keepalive_timeout'] = 65
default['nginx']['performance']['keepalive_requests'] = 100
default['nginx']['performance']['client_body_buffer_size'] = '8k'
default['nginx']['performance']['client_max_body_size'] = '1m'

# Base configuration
default['nginx']['config']['charset'] = 'utf-8'
default['nginx']['config']['types_hash_max_size'] = 2048
default['nginx']['config']['server_names_hash_bucket_size'] = 64
default['nginx']['config']['server_names_hash_max_size'] = 512
default['nginx']['config']['server_tokens'] = 'off'
default['nginx']['config']['log_format'] = {
  'main' => '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"',
  'json' => '{"time":"$time_local","remote_addr":"$remote_addr","remote_user":"$remote_user","request":"$request","status":$status,"body_bytes_sent":$body_bytes_sent,"request_time":$request_time,"http_referrer":"$http_referer","http_user_agent":"$http_user_agent","http_x_forwarded_for":"$http_x_forwarded_for"}',
}
default['nginx']['config']['access_log'] = 'on'
default['nginx']['config']['error_log'] = 'warn'

# Security configuration
default['nginx']['security']['limit_conn_zone'] = '$binary_remote_addr zone=addr:10m'
default['nginx']['security']['limit_conn'] = 'addr 100'
default['nginx']['security']['limit_req_zone'] = '$binary_remote_addr zone=req_limit:10m rate=1r/s'
default['nginx']['security']['limit_req'] = 'zone=req_limit burst=10'
default['nginx']['security']['add_headers'] = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block',
  'Referrer-Policy' => 'strict-origin-when-cross-origin',
}
default['nginx']['security']['hide_headers'] = %w(
  Server
  X-Powered-By
)

# SSL/TLS Configuration
default['nginx']['ssl']['enabled'] = true
default['nginx']['ssl']['port'] = 443
default['nginx']['ssl']['protocols'] = 'TLSv1.2 TLSv1.3'
default['nginx']['ssl']['ciphers'] =
  'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384'
default['nginx']['ssl']['prefer_server_ciphers'] = 'off'
default['nginx']['ssl']['session_tickets'] = 'off'
default['nginx']['ssl']['session_timeout'] = '1d'
default['nginx']['ssl']['session_cache'] = 'shared:SSL:10m'
default['nginx']['ssl']['stapling'] = 'on'
default['nginx']['ssl']['stapling_verify'] = 'on'
default['nginx']['ssl']['certificate'] = nil
default['nginx']['ssl']['certificate_key'] = nil
default['nginx']['ssl']['dhparam'] = nil
default['nginx']['ssl']['hsts'] = true
default['nginx']['ssl']['hsts_max_age'] = 15_768_000
default['nginx']['ssl']['hsts_include_subdomains'] = true
default['nginx']['ssl']['hsts_preload'] = false
default['nginx']['ssl']['redirect_http_to_https'] = true

# Default modules to enable
default['nginx']['modules'] = %w(
  http_ssl
  http_v2
  http_gzip_static
  http_stub_status
)

# Default modules to disable
default['nginx']['disabled_modules'] = %w()

# Default site
default['nginx']['default_site'] = {
  'port' => 80,
  'root' => '/var/www/html',
  'server_name' => node['fqdn'] || 'localhost',
  'error_log' => 'logs/error.log',
  'access_log' => 'logs/access.log combined',
  'enabled' => true,
}

# Define sites to create (empty by default)
default['nginx']['sites'] = {}

# OS-specific tuning
case node['platform_family']
when 'rhel', 'fedora', 'amazon'
  # SELinux configurations
  default['nginx']['selinux']['enabled'] = true
  default['nginx']['selinux']['ports'] = [80, 443]
  default['nginx']['selinux']['http_context'] = 'httpd_sys_content_t'
  default['nginx']['selinux']['allow_http_connections'] = true
when 'debian'
  # AppArmor configurations
  default['nginx']['apparmor']['enabled'] = true
  default['nginx']['apparmor']['profile'] = '/etc/apparmor.d/usr.sbin.nginx'
when 'freebsd'
  # FreeBSD-specific settings
  default['nginx']['rc_conf']['nginx_enable'] = 'YES'
  default['nginx']['logrotate']['postrotate'] = '/usr/sbin/service nginx reload > /dev/null 2>&1 || true'
when 'mac_os_x'
  # macOS-specific settings (using Homebrew services)
  default['nginx']['logrotate']['enabled'] = false # macOS uses newsyslog
  default['nginx']['use_homebrew_service'] = true
end

# Firewall configuration
default['nginx']['firewall']['enabled'] = true
default['nginx']['firewall']['allow_ports'] = [80, 443]
default['nginx']['firewall']['source_addresses'] = %w(0.0.0.0/0 ::/0)

# Monitoring configuration
default['nginx']['monitoring']['status_path'] = '/nginx_status'
default['nginx']['monitoring']['restricted_access'] = true
default['nginx']['monitoring']['allowed_ips'] = %w(127.0.0.1 ::1)

# Logging
default['nginx']['logrotate']['enabled'] = true
default['nginx']['logrotate']['rotate'] = 52
default['nginx']['logrotate']['frequency'] = 'weekly'
default['nginx']['logrotate']['options'] = %w(missingok compress delaycompress notifempty create)
default['nginx']['logrotate']['postrotate'] = '/bin/systemctl reload nginx.service > /dev/null 2>&1 || true'

# Health check
default['nginx']['health_check']['enabled'] = true
default['nginx']['health_check']['path'] = '/health-check'
default['nginx']['health_check']['content'] = 'OK'

# Telemetry configuration
default['nginx']['telemetry']['enabled'] = false
default['nginx']['telemetry']['prometheus']['enabled'] = true
default['nginx']['telemetry']['prometheus']['scrape_uri'] = '/nginx_status'
default['nginx']['telemetry']['prometheus']['telemetry_path'] = '/metrics'
default['nginx']['telemetry']['prometheus']['metrics'] = %w(
  connections
  requests
  http
  ssl
  upstreams
)
default['nginx']['telemetry']['prometheus']['allow_ips'] = %w(127.0.0.1 ::1)
default['nginx']['telemetry']['prometheus']['exporter_version'] = '1.3.0'
default['nginx']['telemetry']['prometheus']['exporter_checksum'] = nil # Set to verify download integrity
default['nginx']['telemetry']['grafana']['enabled'] = false
default['nginx']['telemetry']['grafana']['url'] = 'http://localhost:3000'
default['nginx']['telemetry']['grafana']['datasource'] = 'Prometheus'
default['nginx']['telemetry']['grafana']['api_key'] = nil

# =============================================================================
# Let's Encrypt / ACME Configuration
# =============================================================================

default['nginx']['letsencrypt']['enabled'] = false
default['nginx']['letsencrypt']['email'] = nil # Required for Let's Encrypt
default['nginx']['letsencrypt']['webroot'] = '/var/www/letsencrypt'
default['nginx']['letsencrypt']['staging'] = false # Use staging for testing
default['nginx']['letsencrypt']['key_size'] = 4096
default['nginx']['letsencrypt']['renew_before_days'] = 30
default['nginx']['letsencrypt']['domains'] = [] # Array of domain configs

# =============================================================================
# Upstream / Load Balancing Configuration
# =============================================================================

default['nginx']['upstreams'] = {} # Hash of upstream configurations

# Default upstream settings
default['nginx']['upstream_defaults'] = {
  'method' => 'round_robin', # round_robin, least_conn, ip_hash, random
  'keepalive' => 32,
  'keepalive_requests' => 1000,
  'keepalive_timeout' => '60s',
  'fail_timeout' => '10s',
  'max_fails' => 3,
}

# =============================================================================
# Stream (TCP/UDP) Proxy Configuration
# =============================================================================

default['nginx']['stream']['enabled'] = false
default['nginx']['stream']['upstreams'] = {}
default['nginx']['stream']['servers'] = []

# =============================================================================
# Rate Limiting Configuration
# =============================================================================

default['nginx']['rate_limit']['enabled'] = true
default['nginx']['rate_limit']['zones'] = {
  'default' => {
    'key' => '$binary_remote_addr',
    'size' => '10m',
    'rate' => '10r/s',
  },
  'api' => {
    'key' => '$binary_remote_addr',
    'size' => '10m',
    'rate' => '100r/s',
  },
}

# =============================================================================
# Caching Configuration
# =============================================================================

default['nginx']['cache']['enabled'] = false
default['nginx']['cache']['path'] = '/var/cache/nginx'
default['nginx']['cache']['levels'] = '1:2'
default['nginx']['cache']['keys_zone'] = 'default_cache:10m'
default['nginx']['cache']['max_size'] = '1g'
default['nginx']['cache']['inactive'] = '60m'
default['nginx']['cache']['use_temp_path'] = false
