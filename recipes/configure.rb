# frozen_string_literal: true

#
# Cookbook:: nginx
# Recipe:: configure
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

# Create required directories
%W(
  #{node['nginx']['conf_dir']}
  #{node['nginx']['conf_dir']}/conf.d
  #{node['nginx']['log_dir']}
).each do |dir|
  directory dir do
    owner 'root'
    group node['root_group']
    mode '0755'
    recursive true
  end
end

# Create sites directories if they don't exist
if platform_family?('debian')
  %W(
    #{node['nginx']['sites_available_dir']}
    #{node['nginx']['sites_dir']}
  ).each do |sites_dir|
    directory sites_dir do
      owner 'root'
      group node['root_group']
      mode '0755'
      recursive true
    end
  end
else
  directory node['nginx']['sites_dir'] do
    owner 'root'
    group node['root_group']
    mode '0755'
    recursive true
  end
end

# Generate DH parameters for nginx if enabled
if node['nginx']['ssl']['enabled'] && node['nginx']['ssl']['dhparam'].nil?
  dhparam_file = "#{node['nginx']['conf_dir']}/dhparam.pem"

  # Generate Diffie-Hellman parameters
  execute 'generate-dhparam' do
    command "openssl dhparam -out #{dhparam_file} 2048"
    not_if { ::File.exist?(dhparam_file) }
    notifies :reload, 'service[nginx]', :delayed
  end

  # Set the dhparam attribute
  node.default['nginx']['ssl']['dhparam'] = dhparam_file
end

# Main nginx configuration file
template "#{node['nginx']['conf_dir']}/nginx.conf" do
  source 'nginx.conf.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  variables(
    worker_processes: node['nginx']['performance']['worker_processes'],
    worker_connections: node['nginx']['performance']['worker_connections'],
    worker_rlimit_nofile: node['nginx']['performance']['worker_rlimit_nofile'],
    worker_shutdown_timeout: node['nginx']['performance']['worker_shutdown_timeout'],
    worker_cpu_affinity: node['nginx']['performance']['worker_cpu_affinity'],
    multi_accept: node['nginx']['performance']['multi_accept'],
    sendfile: node['nginx']['performance']['sendfile'],
    tcp_nopush: node['nginx']['performance']['tcp_nopush'],
    tcp_nodelay: node['nginx']['performance']['tcp_nodelay'],
    keepalive_timeout: node['nginx']['performance']['keepalive_timeout'],
    keepalive_requests: node['nginx']['performance']['keepalive_requests'],
    client_body_buffer_size: node['nginx']['performance']['client_body_buffer_size'],
    client_max_body_size: node['nginx']['performance']['client_max_body_size'],
    log_dir: node['nginx']['log_dir'],
    error_log: node['nginx']['error_log'],
    error_log_level: node['nginx']['config']['error_log'],
    pid_file: node['nginx']['pid_file'],
    conf_dir: node['nginx']['conf_dir'],
    user: node['nginx']['user'],
    group: node['nginx']['group'],
    open_file_cache_max: node['nginx']['performance']['open_file_cache_max'],
    open_file_cache_inactive: node['nginx']['performance']['open_file_cache_inactive'],
    open_file_cache_valid: node['nginx']['performance']['open_file_cache_valid'],
    open_file_cache_min_uses: node['nginx']['performance']['open_file_cache_min_uses'],
    open_file_cache_errors: node['nginx']['performance']['open_file_cache_errors'],
    log_formats: node['nginx']['config']['log_format'],
    access_log: node['nginx']['config']['access_log'],
    charset: node['nginx']['config']['charset'],
    server_tokens: node['nginx']['config']['server_tokens'],
    server_names_hash_bucket_size: node['nginx']['config']['server_names_hash_bucket_size'],
    server_names_hash_max_size: node['nginx']['config']['server_names_hash_max_size'],
    types_hash_max_size: node['nginx']['config']['types_hash_max_size'],
    sites_dir: node['nginx']['sites_dir']
  )
  notifies :reload, 'service[nginx]', :delayed
end

# Security configuration
template "#{node['nginx']['conf_dir']}/conf.d/security.conf" do
  source 'security.conf.erb'
  owner 'root'
  group node['root_group']
  mode '0644'
  variables(
    limit_conn_zone: node['nginx']['security']['limit_conn_zone'],
    limit_conn: node['nginx']['security']['limit_conn'],
    limit_req_zone: node['nginx']['security']['limit_req_zone'],
    limit_req: node['nginx']['security']['limit_req'],
    add_headers: node['nginx']['security']['add_headers'],
    hide_headers: node['nginx']['security']['hide_headers']
  )
  notifies :reload, 'service[nginx]', :delayed
end

# SSL configuration if enabled
if node['nginx']['ssl']['enabled']
  template "#{node['nginx']['conf_dir']}/conf.d/ssl.conf" do
    source 'ssl.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    variables(
      ssl_protocols: node['nginx']['ssl']['protocols'],
      ssl_ciphers: node['nginx']['ssl']['ciphers'],
      ssl_prefer_server_ciphers: node['nginx']['ssl']['prefer_server_ciphers'],
      ssl_session_tickets: node['nginx']['ssl']['session_tickets'],
      ssl_session_timeout: node['nginx']['ssl']['session_timeout'],
      ssl_session_cache: node['nginx']['ssl']['session_cache'],
      ssl_dhparam: node['nginx']['ssl']['dhparam'],
      ssl_stapling: node['nginx']['ssl']['stapling'],
      ssl_stapling_verify: node['nginx']['ssl']['stapling_verify']
    )
    notifies :reload, 'service[nginx]', :delayed
  end
end

# Monitoring/status configuration
if node['nginx']['monitoring']['status_path']
  template "#{node['nginx']['conf_dir']}/conf.d/status.conf" do
    source 'status.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    variables(
      status_path: node['nginx']['monitoring']['status_path'],
      restricted_access: node['nginx']['monitoring']['restricted_access'],
      allowed_ips: node['nginx']['monitoring']['allowed_ips']
    )
    notifies :reload, 'service[nginx]', :delayed
  end
end

# Create a health check location if enabled
if node['nginx']['health_check']['enabled']
  template "#{node['nginx']['conf_dir']}/conf.d/health-check.conf" do
    source 'health-check.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    variables(
      health_check_path: node['nginx']['health_check']['path'],
      health_check_content: node['nginx']['health_check']['content']
    )
    notifies :reload, 'service[nginx]', :delayed
  end
end

# Configure logrotate
if node['nginx']['logrotate']['enabled']
  template '/etc/logrotate.d/nginx' do
    source 'logrotate.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    variables(
      logs: ["#{node['nginx']['log_dir']}/*.log"],
      frequency: node['nginx']['logrotate']['frequency'],
      rotate: node['nginx']['logrotate']['rotate'],
      options: node['nginx']['logrotate']['options'],
      postrotate: node['nginx']['logrotate']['postrotate']
    )
  end
end
