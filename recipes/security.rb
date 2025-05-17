#
# Cookbook:: nginx
# Recipe:: security
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

# Create security configuration using nginx_config resource
nginx_config 'security' do
  source 'security.conf.erb'
  cookbook 'nginx'
  variables(
    server_tokens: node['nginx']['security']['server_tokens'],
    client_body_buffer_size: node['nginx']['security']['client_body_buffer_size'],
    client_max_body_size: node['nginx']['security']['client_max_body_size'],
    hide_headers: node['nginx']['security']['hide_headers']
  )
  notifies :reload, 'nginx_service[default]', :delayed
  action :create
end

# Create SSL configuration if enabled
if node['nginx']['security']['ssl_enabled']
  nginx_config 'ssl' do
    source 'ssl.conf.erb'
    cookbook 'nginx'
    variables(
      ssl_protocols: node['nginx']['security']['ssl_protocols'],
      ssl_ciphers: node['nginx']['security']['ssl_ciphers'],
      ssl_prefer_server_ciphers: node['nginx']['security']['ssl_prefer_server_ciphers'],
      ssl_session_cache: node['nginx']['security']['ssl_session_cache'],
      ssl_session_timeout: node['nginx']['security']['ssl_session_timeout'],
      ssl_stapling: node['nginx']['security']['ssl_stapling'],
      ssl_stapling_verify: node['nginx']['security']['ssl_stapling_verify']
    )
    notifies :reload, 'nginx_service[default]', :delayed
    action :create
  end
end

# Configure SELinux for Nginx if applicable
if platform_family?('rhel', 'fedora', 'amazon')
  selinux_install 'nginx' do
    action :install
    only_if { node['nginx']['security']['selinux_enabled'] }
  end

  selinux_module 'nginx' do
    action :install
    content <<~EOM
      module nginx 1.0;

      require {
        type httpd_t;
        type http_port_t;
        class tcp_socket name_bind;
      }

      #============= httpd_t ==============
      allow httpd_t http_port_t:tcp_socket name_bind;
    EOM
    only_if { node['nginx']['security']['selinux_enabled'] }
  end
end

# Configure AppArmor for Nginx if applicable
if platform_family?('debian')
  file '/etc/apparmor.d/local/usr.sbin.nginx' do
    content <<~EOM
      # Site-specific additions and overrides for usr.sbin.nginx.
      # For more details, please see /etc/apparmor.d/local/README.

      #{node['nginx']['conf_dir']}/** r,
      #{node['nginx']['log_dir']}/** rw,
      #{node['nginx']['pid_file']} rw,
    EOM
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'nginx_service[default]', :delayed
    only_if { node['nginx']['security']['apparmor_enabled'] && ::File.exist?('/etc/apparmor.d/usr.sbin.nginx') }
  end
end
