# frozen_string_literal: true

#
# Cookbook:: nginx
# Recipe:: install
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

# Declare service resource for notifications from this recipe
service 'nginx' do
  action :nothing
end

case node['platform_family']
when 'debian'
  # Use OS-provided nginx packages (available on all modern Debian/Ubuntu)
  apt_update 'nginx' do
    action :update
  end

when 'rhel', 'amazon'
  yum_repository 'nginx' do
    description 'Nginx Repository'
    baseurl 'https://nginx.org/packages/rhel/$releasever/$basearch/'
    gpgcheck true
    gpgkey 'https://nginx.org/keys/nginx_signing.key'
    enabled true
    action :create
    only_if { node['nginx']['install_method'] == 'package' }
  end

  include_recipe 'yum-epel::default' if platform_family?('rhel')

when 'freebsd'
  # FreeBSD uses pkg for package management
  # Ensure pkg is bootstrapped
  execute 'bootstrap_pkg' do
    command 'pkg bootstrap -y'
    not_if 'pkg -N'
  end

when 'mac_os_x'
  # macOS uses Homebrew for nginx installation
  unless ::File.exist?('/opt/homebrew/bin/brew') || ::File.exist?('/usr/local/bin/brew')
    log 'homebrew_required' do
      message 'Homebrew is required for nginx installation on macOS. Please install: https://brew.sh'
      level :error
    end
  end
end

# Install nginx package based on platform
case node['platform_family']
when 'debian'
  # Use execute to handle nginx virtual package on Debian/Ubuntu
  execute 'install-nginx' do
    command "DEBIAN_FRONTEND=noninteractive apt-get install -y #{node['nginx']['package_name']}"
    not_if 'dpkg -l nginx-core 2>/dev/null | grep -q ^ii || dpkg -l nginx-light 2>/dev/null | grep -q ^ii'
    notifies :reload, 'service[nginx]', :delayed
    only_if { node['nginx']['install_method'] == 'package' }
  end

when 'rhel', 'amazon', 'suse'
  package node['nginx']['package_name'] do
    action :install
    version node['nginx']['version'] if node['nginx']['version']
    notifies :reload, 'service[nginx]', :delayed
    only_if { node['nginx']['install_method'] == 'package' }
  end

when 'freebsd'
  package 'nginx' do
    action :install
    only_if { node['nginx']['install_method'] == 'package' }
  end

when 'mac_os_x'
  homebrew_package 'nginx' do
    action :install
    only_if { node['nginx']['install_method'] == 'package' }
    only_if { ::File.exist?('/opt/homebrew/bin/brew') || ::File.exist?('/usr/local/bin/brew') }
  end
end

if node['nginx']['install_method'] == 'source'
  # Install build dependencies
  build_essential 'install_build_tools' do
    action :install
  end

  node['nginx']['source']['dependencies'].each do |pkg|
    package pkg do
      action :install
    end
  end

  # Download nginx source
  remote_file "#{Chef::Config['file_cache_path']}/nginx-#{node['nginx']['version']}.tar.gz" do
    source node['nginx']['source']['url']
    checksum node['nginx']['source']['checksum'] if node['nginx']['source']['checksum']
    action :create
  end

  # Create user and group for nginx
  group node['nginx']['group'] do
    system true
    action :create
  end

  user node['nginx']['user'] do
    system true
    gid node['nginx']['group']
    shell '/bin/false'
    action :create
  end

  # Make sure the required directories exist
  directory node['nginx']['log_dir'] do
    owner node['nginx']['user']
    group node['nginx']['group']
    mode '0755'
    recursive true
    action :create
  end

  directory node['nginx']['conf_dir'] do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action :create
  end

  # Extract and compile nginx
  bash 'compile_nginx_source' do
    cwd Chef::Config['file_cache_path']
    code <<-EOH
      tar zxf nginx-#{node['nginx']['version']}.tar.gz
      cd nginx-#{node['nginx']['version']}
      ./configure #{node['nginx']['source']['configure_options'].join(' ')} \
        --prefix=#{node['nginx']['source']['prefix']} \
        --conf-path=#{node['nginx']['conf_dir']}/nginx.conf \
        --sbin-path=#{node['nginx']['binary']} \
        --pid-path=#{node['nginx']['pid_file']} \
        --error-log-path=#{node['nginx']['error_log']} \
        --http-log-path=#{node['nginx']['access_log']} \
        --user=#{node['nginx']['user']} \
        --group=#{node['nginx']['group']} \
        --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic'
      make
      make install
    EOH
    action :run
    notifies :restart, 'service[nginx]', :delayed
    not_if { ::File.exist?(node['nginx']['binary']) && `/usr/sbin/nginx -v 2>&1` =~ /#{node['nginx']['version']}/ }
  end

  # Create systemd service
  template '/lib/systemd/system/nginx.service' do
    source 'nginx.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, 'execute[systemctl-daemon-reload]', :immediately
    variables(
      nginx_binary: node['nginx']['binary'],
      pid_file: node['nginx']['pid_file']
    )
  end

  execute 'systemctl-daemon-reload' do
    command 'systemctl daemon-reload'
    action :nothing
  end
end
