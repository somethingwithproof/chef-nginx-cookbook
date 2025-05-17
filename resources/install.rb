#
# Cookbook:: nginx
# Resource:: install
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

property :version, String, default: lazy { node['nginx']['version'] }
property :install_method, String, equal_to: %w(package source), default: lazy { node['nginx']['install_method'] }
property :package_name, String, default: lazy { node['nginx']['package_name'] }
property :source_url, String, default: lazy { node['nginx']['source']['url'] }
property :source_checksum, [String, nil], default: nil
property :configure_flags, Array, default: lazy { node['nginx']['source']['configure_flags'] }
property :use_official_repo, [true, false], default: lazy { node['nginx']['repo']['use_official_repo'] }
property :repo_url, String, default: lazy { node['nginx']['repo']['url'] }
property :repo_key, String, default: lazy { node['nginx']['repo']['key'] }
property :user, String, default: lazy { node['nginx']['user'] }
property :group, String, default: lazy { node['nginx']['group'] }

action :install do
  # Create nginx user and group if installing from source
  if new_resource.install_method == 'source'
    group new_resource.group do
      system true
    end

    user new_resource.user do
      gid new_resource.group
      system true
      shell '/sbin/nologin'
      comment 'Nginx user'
    end
  end

  case new_resource.install_method
  when 'package'
    if new_resource.use_official_repo
      include_recipe 'apt' if platform_family?('debian')
      include_recipe 'yum-epel' if platform_family?('rhel')
      
      # Set up official NGINX repository
      case node['platform_family']
      when 'debian'
        apt_repository 'nginx' do
          uri new_resource.repo_url
          distribution node['lsb']['codename']
          components ['nginx']
          key new_resource.repo_key
          action :add
        end
      when 'rhel', 'amazon'
        # Create yum repo file
        yum_repository 'nginx' do
          description 'Official NGINX Repository'
          baseurl new_resource.repo_url
          gpgcheck true
          gpgkey new_resource.repo_key
          enabled true
          action :create
        end
      end
    end

    # Install nginx package
    package new_resource.package_name do
      action :install
      version new_resource.version unless new_resource.version == 'latest'
    end
  when 'source'
    # Install dependencies for building from source
    build_essential 'nginx_build_dependencies' do
      compile_time true
    end

    # Install required packages
    package %w(libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev) do
      action :install
      only_if { platform_family?('debian') }
    end

    package %w(pcre pcre-devel zlib zlib-devel openssl openssl-devel) do
      action :install
      only_if { platform_family?('rhel', 'amazon') }
    end

    # Create directories if not present
    directory '/opt/nginx-source' do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
    end

    # Download and extract source
    remote_file "#{Chef::Config[:file_cache_path]}/nginx-#{new_resource.version}.tar.gz" do
      source new_resource.source_url
      checksum new_resource.source_checksum if new_resource.source_checksum
      mode '0644'
      backup false
    end

    # Build and install
    bash 'compile_nginx_source' do
      cwd Chef::Config[:file_cache_path]
      code <<~EOH
        tar -zxf nginx-#{new_resource.version}.tar.gz
        cd nginx-#{new_resource.version}
        ./configure #{new_resource.configure_flags.join(' ')}
        make -j#{node['cpu']['total']}
        make install
      EOH

      not_if { ::File.exist?('/opt/nginx/sbin/nginx') && `/opt/nginx/sbin/nginx -v 2>&1` =~ /nginx\/#{new_resource.version}/ }
    end

    # Create system service for source-based installation
    template '/lib/systemd/system/nginx.service' do
      source 'nginx.service.erb'
      cookbook 'nginx'
      owner 'root'
      group 'root'
      mode '0644'
      variables(
        binary: '/opt/nginx/sbin/nginx',
        pid_file: '/run/nginx.pid'
      )
      notifies :run, 'execute[systemctl daemon-reload]', :immediately
    end

    execute 'systemctl daemon-reload' do
      command 'systemctl daemon-reload'
      action :nothing
    end
  end

  # Create necessary directories if they don't exist
  %w(conf_dir sites_dir sites_enabled_dir log_dir).each do |dir|
    directory node['nginx'][dir] do
      owner 'root'
      group node['root_group']
      mode '0755'
      recursive true
    end
  end
end

action :remove do
  case new_resource.install_method
  when 'package'
    package new_resource.package_name do
      action :remove
    end
    
    # Remove repository if added
    if new_resource.use_official_repo
      case node['platform_family']
      when 'debian'
        apt_repository 'nginx' do
          action :remove
        end
      when 'rhel', 'amazon'
        yum_repository 'nginx' do
          action :remove
        end
      end
    end
  when 'source'
    # Stop and disable service
    service 'nginx' do
      action [:stop, :disable]
    end
    
    # Remove source-built NGINX
    file '/opt/nginx/sbin/nginx' do
      action :delete
    end
    
    file '/lib/systemd/system/nginx.service' do
      action :delete
      notifies :run, 'execute[systemctl daemon-reload]', :immediately
    end
    
    execute 'systemctl daemon-reload' do
      command 'systemctl daemon-reload'
      action :nothing
    end
  end
  
  # Remove conf directories
  %w(conf_dir sites_dir sites_enabled_dir).each do |dir|
    directory node['nginx'][dir] do
      action :delete
      recursive true
    end
  end
  
  # Optionally remove logs
  directory node['nginx']['log_dir'] do
    action :delete
    recursive true
  end
end
