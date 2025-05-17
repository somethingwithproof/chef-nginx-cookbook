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
#

# Main nginx configuration file
nginx_config 'nginx' do
  source 'nginx.conf.erb'
  config_name 'nginx.conf'
  template_location ''
  variables(
    worker_processes: node['nginx']['performance']['worker_processes'],
    worker_connections: node['nginx']['performance']['worker_connections'],
    worker_rlimit_nofile: node['nginx']['performance']['worker_rlimit_nofile'],
    multi_accept: node['nginx']['performance']['multi_accept'],
    sendfile: node['nginx']['performance']['sendfile'],
    tcp_nopush: node['nginx']['performance']['tcp_nopush'],
    tcp_nodelay: node['nginx']['performance']['tcp_nodelay'],
    keepalive_timeout: node['nginx']['performance']['keepalive_timeout'],
    keepalive_requests: node['nginx']['performance']['keepalive_requests'],
    client_body_buffer_size: node['nginx']['performance']['client_body_buffer_size'],
    client_max_body_size: node['nginx']['performance']['client_max_body_size'],
    log_dir: node['nginx']['log_dir'],
    error_log_level: node['nginx']['config']['error_log_level'] || 'error',
    pid_file: node['nginx']['pid_file'],
    conf_dir: node['nginx']['conf_dir'],
    user: node['nginx']['user'],
    group: node['nginx']['group'],
    open_file_cache: node['nginx']['performance']['open_file_cache'],
    open_file_cache_valid: node['nginx']['performance']['open_file_cache_valid'],
    open_file_cache_min_uses: node['nginx']['performance']['open_file_cache_min_uses'],
    open_file_cache_errors: node['nginx']['performance']['open_file_cache_errors'],
    gzip: node['nginx']['performance']['gzip'],
    gzip_comp_level: node['nginx']['performance']['gzip_comp_level'],
    gzip_types: node['nginx']['performance']['gzip_types'],
    gzip_disable: node['nginx']['performance']['gzip_disable'],
    server_tokens: node['nginx']['security']['server_tokens'],
    sites_dir: node['nginx']['sites_dir'],
    sites_enabled_dir: node['nginx']['sites_enabled_dir']
  )
  notifies :reload, 'nginx_service[default]', :delayed
end

# Generate DH parameters for nginx if enabled
if node['nginx']['security']['ssl_enabled'] && !node['nginx']['security']['dhparam_file']
  dhparam_file = "#{node['nginx']['conf_dir']}/dhparam.pem"
  
  # Generate Diffie-Hellman parameters
  execute 'generate-dhparam' do
    command "openssl dhparam -out #{dhparam_file} 2048"
    not_if { ::File.exist?(dhparam_file) }
    notifies :reload, 'nginx_service[default]', :delayed
  end
  
  # Set the dhparam attribute
  node.run_state['nginx_dhparam_file'] = dhparam_file
end

# Configure status module for monitoring
if node['nginx']['telemetry']['status_enabled']
  nginx_config 'status' do
    source 'status.conf.erb'
    variables(
      status_port: node['nginx']['telemetry']['status_port'],
      status_allow_ips: node['nginx']['telemetry']['status_allow_ips']
    )
    notifies :reload, 'nginx_service[default]', :delayed
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
