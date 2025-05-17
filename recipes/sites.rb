#
# Cookbook:: nginx
# Recipe:: sites
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

# Setup default site if enabled
if node['nginx']['default_site_enabled']
  nginx_site 'default' do
    site_name 'default'
    domain 'localhost'
    port 80
    root '/var/www/html'
    # Use the custom variables
    variables(welcome_message: 'If you see this page, the nginx web server is successfully installed and working.')
    action :create
  end
end

# Configure virtual hosts from attributes
node['nginx']['sites'].each do |site_name, site_data|
  nginx_site site_name do
    domain site_data['domain'] || site_name
    site_name site_name
    port site_data['port'] || 80
    root site_data['root'] || "/var/www/#{site_name}"
    server_name site_data['server_name'] || site_data['domain'] || site_name
    access_log site_data['access_log'] || "#{node['nginx']['log_dir']}/#{site_name}.access.log"
    error_log site_data['error_log'] || "#{node['nginx']['log_dir']}/#{site_name}.error.log"
    index site_data['index'] || 'index.html index.htm'
    template site_data['template'] || 'site.conf.erb'
    cookbook site_data['cookbook'] || 'nginx'
    ssl_enabled site_data['ssl_enabled'] || false
    
    if site_data['ssl_enabled']
      ssl_port site_data['ssl_port'] || 443
      ssl_protocols site_data['ssl_protocols'] || node['nginx']['security']['ssl_protocols']
      ssl_ciphers site_data['ssl_ciphers'] || node['nginx']['security']['ssl_ciphers']
      ssl_cert site_data['ssl_cert']
      ssl_key site_data['ssl_key']
      ssl_chain site_data['ssl_chain'] if site_data['ssl_chain']
      redirect_http_to_https site_data['redirect_http_to_https'] || false
    end
    
    custom_directives site_data['custom_directives'] if site_data['custom_directives']
    client_max_body_size site_data['client_max_body_size'] if site_data['client_max_body_size']
    proxy_pass site_data['proxy_pass'] if site_data['proxy_pass']
    proxy_set_header site_data['proxy_set_header'] if site_data['proxy_set_header']
    php_fpm_enabled site_data['php_fpm_enabled'] || false
    php_fpm_socket site_data['php_fpm_socket'] if site_data['php_fpm_socket']
    
    health_check_enabled site_data['health_check_enabled'] || false
    health_check_path site_data['health_check_path'] || '/health'
    health_check_interval site_data['health_check_interval'] || '10s'
    
    enable true
    action :create
  end
end
