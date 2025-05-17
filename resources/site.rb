#
# Cookbook:: nginx
# Resource:: site
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

property :domain, String, name_property: true
property :site_name, String, default: lazy { domain }
property :port, Integer, default: 80
property :root, String, required: true
property :server_name, [Array, String], default: lazy { domain }
property :access_log, [String, false], default: lazy { ::File.join(node['nginx']['log_dir'], "#{domain}.access.log") }
property :error_log, [String, false], default: lazy { ::File.join(node['nginx']['log_dir'], "#{domain}.error.log") }
property :index, [String, Array], default: 'index.html index.htm'
property :template, String, default: 'site.conf.erb'
property :cookbook, String, default: 'nginx'
property :variables, Hash, default: {}
property :enable, [true, false], default: true

# SSL settings
property :ssl_enabled, [true, false], default: false
property :ssl_port, Integer, default: 443
property :ssl_protocols, String, default: lazy { node['nginx']['security']['ssl_protocols'] }
property :ssl_ciphers, String, default: lazy { node['nginx']['security']['ssl_ciphers'] }
property :ssl_cert, String
property :ssl_key, String
property :ssl_chain, [String, nil], default: nil
property :redirect_http_to_https, [true, false], default: false

# Server specific settings
property :custom_directives, [Array, String, nil], default: nil
property :client_max_body_size, String
property :proxy_pass, [String, nil], default: nil
property :proxy_set_header, Hash, default: {}
property :php_fpm_enabled, [true, false], default: false
property :php_fpm_socket, String, default: '/var/run/php/php-fpm.sock'
property :health_check_enabled, [true, false], default: false
property :health_check_path, String, default: '/health'
property :health_check_interval, String, default: '10s'

action :create do
  # Handle string or array for index
  index = new_resource.index.is_a?(Array) ? new_resource.index.join(' ') : new_resource.index

  # Handle string or array for server_name
  server_name = if new_resource.server_name.is_a?(Array)
                  new_resource.server_name.join(' ')
                else
                  new_resource.server_name
                end

  # Handle string or array for custom_directives
  custom_directives = if new_resource.custom_directives.is_a?(Array)
                        new_resource.custom_directives.join("\n")
                      else
                        new_resource.custom_directives
                      end

  # Create site configuration from template
  template "#{node['nginx']['sites_dir']}/#{new_resource.site_name}.conf" do
    source new_resource.template
    cookbook new_resource.cookbook
    variables(
      new_resource.variables.merge(
        domain: new_resource.domain,
        port: new_resource.port,
        root: new_resource.root,
        server_name: server_name,
        access_log: new_resource.access_log,
        error_log: new_resource.error_log,
        index: index,
        ssl_enabled: new_resource.ssl_enabled,
        ssl_port: new_resource.ssl_port,
        ssl_protocols: new_resource.ssl_protocols,
        ssl_ciphers: new_resource.ssl_ciphers,
        ssl_cert: new_resource.ssl_cert,
        ssl_key: new_resource.ssl_key,
        ssl_chain: new_resource.ssl_chain,
        redirect_http_to_https: new_resource.redirect_http_to_https,
        custom_directives: custom_directives,
        client_max_body_size: new_resource.client_max_body_size,
        proxy_pass: new_resource.proxy_pass,
        proxy_set_header: new_resource.proxy_set_header,
        php_fpm_enabled: new_resource.php_fpm_enabled,
        php_fpm_socket: new_resource.php_fpm_socket,
        health_check_enabled: new_resource.health_check_enabled,
        health_check_path: new_resource.health_check_path,
        health_check_interval: new_resource.health_check_interval
      )
    )
    owner 'root'
    group node['root_group']
    mode '0644'
    action :create
    notifies :reload, 'nginx_service[default]', :delayed
  end

  # Enable site by creating symbolic link in sites-enabled directory
  link "#{node['nginx']['sites_enabled_dir']}/#{new_resource.site_name}.conf" do
    to "#{node['nginx']['sites_dir']}/#{new_resource.site_name}.conf"
    only_if { platform_family?('debian') && new_resource.enable }
    notifies :reload, 'nginx_service[default]', :delayed
  end

  # Create the document root directory if it doesn't exist
  directory new_resource.root do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0755'
    recursive true
    action :create
  end
end

action :delete do
  # Remove symbolic link in sites-enabled directory
  link "#{node['nginx']['sites_enabled_dir']}/#{new_resource.site_name}.conf" do
    action :delete
    only_if { platform_family?('debian') }
    notifies :reload, 'nginx_service[default]', :delayed
  end

  # Delete the site configuration file
  file "#{node['nginx']['sites_dir']}/#{new_resource.site_name}.conf" do
    action :delete
    notifies :reload, 'nginx_service[default]', :delayed
  end
end

action :enable do
  # Create symbolic link in sites-enabled directory
  link "#{node['nginx']['sites_enabled_dir']}/#{new_resource.site_name}.conf" do
    to "#{node['nginx']['sites_dir']}/#{new_resource.site_name}.conf"
    only_if { platform_family?('debian') }
    notifies :reload, 'nginx_service[default]', :delayed
  end
end

action :disable do
  # Remove symbolic link in sites-enabled directory
  link "#{node['nginx']['sites_enabled_dir']}/#{new_resource.site_name}.conf" do
    action :delete
    only_if { platform_family?('debian') }
    notifies :reload, 'nginx_service[default]', :delayed
  end
end
