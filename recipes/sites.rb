# frozen_string_literal: true

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

# Setup default site if enabled
if node['nginx']['default_site']['enabled']
  template "#{node['nginx']['sites_dir']}/default.conf" do
    source 'site.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    variables(
      port: node['nginx']['default_site']['port'],
      server_name: node['nginx']['default_site']['server_name'],
      root: node['nginx']['default_site']['root'],
      access_log: node['nginx']['default_site']['access_log'],
      error_log: node['nginx']['default_site']['error_log']
    )
    notifies :reload, 'service[nginx]', :delayed
  end

  # Create document root directory if it doesn't exist
  directory node['nginx']['default_site']['root'] do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0755'
    recursive true
    action :create
    not_if { ::File.directory?(node['nginx']['default_site']['root']) }
  end

  # Create a default index.html
  file "#{node['nginx']['default_site']['root']}/index.html" do
    content '<html><body><h1>Welcome to nginx!</h1><p>If you see this page, the nginx web server is successfully installed and working.</p></body></html>'
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0644'
    action :create_if_missing
  end
else
  file "#{node['nginx']['sites_dir']}/default.conf" do
    action :delete
    notifies :reload, 'service[nginx]', :delayed
    only_if { ::File.exist?("#{node['nginx']['sites_dir']}/default.conf") }
  end
end

# For Debian-based distributions
if platform_family?('debian')
  # Remove the default site symlink if not enabled
  link "#{node['nginx']['sites_dir']}/default" do
    action :delete
    only_if { ::File.exist?("#{node['nginx']['sites_dir']}/default") }
    not_if { node['nginx']['default_site']['enabled'] }
    notifies :reload, 'service[nginx]', :delayed
  end
end

# Configure virtual hosts from attributes
node['nginx']['sites'].each do |site_name, site_data|
  # Determine file name and path
  site_config = "#{site_name}.conf"
  site_available_path = platform_family?('debian') ? "#{node['nginx']['sites_available_dir']}/#{site_config}" : "#{node['nginx']['sites_dir']}/#{site_config}"
  site_enabled_path = "#{node['nginx']['sites_dir']}/#{site_config}"
  
  # Set SSL default values
  if site_data['ssl_enabled'] && (site_data['ssl_cert'].nil? || site_data['ssl_key'].nil?)
    site_data['ssl_cert'] = node['nginx']['ssl']['certificate']
    site_data['ssl_key'] = node['nginx']['ssl']['certificate_key']
  end
  
  # Create the site configuration
  template site_available_path do
    source 'site.conf.erb'
    owner 'root'
    group node['root_group']
    mode '0644'
    variables(
      site_name: site_name,
      port: site_data['port'] || 80,
      server_name: site_data['domain'] || site_name,
      root: site_data['root'] || "/var/www/#{site_name}",
      access_log: site_data['access_log'] || "#{node['nginx']['log_dir']}/#{site_name}.access.log",
      error_log: site_data['error_log'] || "#{node['nginx']['log_dir']}/#{site_name}.error.log",
      ssl_enabled: site_data['ssl_enabled'] || false,
      ssl_cert: site_data['ssl_cert'],
      ssl_key: site_data['ssl_key'],
      ssl_protocols: site_data['ssl_protocols'] || node['nginx']['ssl']['protocols'],
      ssl_ciphers: site_data['ssl_ciphers'] || node['nginx']['ssl']['ciphers'],
      hsts_enabled: site_data['hsts_enabled'] || node['nginx']['ssl']['hsts'],
      hsts_max_age: site_data['hsts_max_age'] || node['nginx']['ssl']['hsts_max_age'],
      hsts_include_subdomains: site_data['hsts_include_subdomains'] || node['nginx']['ssl']['hsts_include_subdomains'],
      hsts_preload: site_data['hsts_preload'] || node['nginx']['ssl']['hsts_preload'],
      redirect_http_to_https: site_data['redirect_http_to_https'] || node['nginx']['ssl']['redirect_http_to_https'],
      custom_directives: site_data['custom_directives']
    )
    notifies :reload, 'service[nginx]', :delayed
  end
  
  # Create document root directory if it doesn't exist
  directory site_data['root'] || "/var/www/#{site_name}" do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0755'
    recursive true
    action :create
    not_if { ::File.directory?(site_data['root'] || "/var/www/#{site_name}") }
  end
  
  # Enable the site for Debian-based distributions
  if platform_family?('debian')
    link site_enabled_path do
      to site_available_path
      action :create
      notifies :reload, 'service[nginx]', :delayed
    end
  end
end