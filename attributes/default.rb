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
#

# General settings
default['nginx']['version'] = '1.24.0'
default['nginx']['install_method'] = 'package' # package, source
default['nginx']['service_name'] = 'nginx'

# Platform-specific settings
case node['platform_family']
when 'debian'
  default['nginx']['package_name'] = 'nginx'
  default['nginx']['conf_dir'] = '/etc/nginx'
  default['nginx']['sites_dir'] = '/etc/nginx/sites-available'
  default['nginx']['sites_enabled_dir'] = '/etc/nginx/sites-enabled'
  default['nginx']['conf_file'] = '/etc/nginx/nginx.conf'
  default['nginx']['log_dir'] = '/var/log/nginx'
  default['nginx']['modules_dir'] = '/etc/nginx/modules-enabled'
  default['nginx']['pid_file'] = '/run/nginx.pid'
  default['nginx']['binary'] = '/usr/sbin/nginx'
when 'rhel', 'amazon'
  default['nginx']['package_name'] = 'nginx'
  default['nginx']['conf_dir'] = '/etc/nginx'
  default['nginx']['sites_dir'] = '/etc/nginx/conf.d'
  default['nginx']['sites_enabled_dir'] = '/etc/nginx/conf.d'
  default['nginx']['conf_file'] = '/etc/nginx/nginx.conf'
  default['nginx']['log_dir'] = '/var/log/nginx'
  default['nginx']['modules_dir'] = '/etc/nginx/conf.d'
  default['nginx']['pid_file'] = '/run/nginx.pid'
  default['nginx']['binary'] = '/usr/sbin/nginx'
end

# Default site settings
default['nginx']['default_site_enabled'] = true
default['nginx']['default_site_template'] = 'site.conf.erb'

# Package installation settings
default['nginx']['repo']['use_official_repo'] = true
default['nginx']['repo']['url'] = case node['platform_family']
                                   when 'debian'
                                     'http://nginx.org/packages/debian'
                                   when 'rhel'
                                     'http://nginx.org/packages/rhel/$releasever/$basearch/'
                                   when 'amazon'
                                     'http://nginx.org/packages/amazon/2/$basearch/'
                                   end
default['nginx']['repo']['key'] = 'https://nginx.org/keys/nginx_signing.key'

# Source installation settings
default['nginx']['source']['url'] = "https://nginx.org/download/nginx-#{node['nginx']['version']}.tar.gz"
default['nginx']['source']['prefix'] = '/opt/nginx'
default['nginx']['source']['configure_flags'] = [
  '--prefix=/opt/nginx',
  '--conf-path=/etc/nginx/nginx.conf',
  '--http-log-path=/var/log/nginx/access.log',
  '--error-log-path=/var/log/nginx/error.log',
  '--pid-path=/run/nginx.pid',
  '--with-http_ssl_module',
  '--with-http_v2_module',
  '--with-http_realip_module',
  '--with-http_addition_module',
  '--with-http_sub_module',
  '--with-http_gunzip_module',
  '--with-http_gzip_static_module',
  '--with-http_stub_status_module',
  '--with-pcre',
  '--with-file-aio',
  '--with-threads',
]

# Define sites from attributes
default['nginx']['sites'] = {}

# User and group
default['nginx']['user'] = case node['platform_family']
                           when 'debian'
                             'www-data'
                           else
                             'nginx'
                           end
default['nginx']['group'] = case node['platform_family']
                            when 'debian'
                              'www-data'
                            else
                              'nginx'
                            end

# Define modules from attributes
default['nginx']['modules'] = {}
