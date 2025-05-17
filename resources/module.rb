#
# Cookbook:: nginx
# Resource:: module
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

unified_mode true

property :module_name, String, name_property: true
property :configuration, [String, nil]
property :install_package, [true, false], default: true
property :module_package_name, [String, nil], default: lazy { "nginx-module-#{module_name}" }
property :module_config_file, String, default: lazy { "#{node['nginx']['modules_dir']}/#{module_name}.conf" }

# For dynamic modules, the load directive
property :module_path, [String, nil]
property :module_priority, Integer, default: 50
property :template, String, default: 'module.conf.erb'
property :cookbook, String, default: 'nginx'
property :extra_packages, Array, default: []

action :enable do
  # Install module package if needed
  if new_resource.install_package && new_resource.module_package_name
    package new_resource.module_package_name do
      action :install
    end
  end

  # Install any extra packages needed for this module
  new_resource.extra_packages.each do |pkg|
    package pkg do
      action :install
    end
  end

  # Create module configuration file
  template new_resource.module_config_file do
    source new_resource.template
    cookbook new_resource.cookbook
    variables(
      module_name: new_resource.module_name,
      configuration: new_resource.configuration,
      module_path: new_resource.module_path,
      module_priority: new_resource.module_priority
    )
    owner 'root'
    group node['root_group']
    mode '0644'
    notifies :reload, 'nginx_service[default]', :delayed
    action :create
  end

  # For Debian-based systems with modules-available and modules-enabled
  if platform_family?('debian') && node['nginx']['modules_dir'] != '/etc/nginx/modules-enabled'
    link "#{node['nginx']['modules_dir']}/#{format('%02d', new_resource.module_priority)}-#{new_resource.module_name}.conf" do
      to new_resource.module_config_file
      notifies :reload, 'nginx_service[default]', :delayed
    end
  end
end

action :disable do
  # For Debian-based systems with modules-available and modules-enabled
  if platform_family?('debian') && node['nginx']['modules_dir'] != '/etc/nginx/modules-enabled'
    link "#{node['nginx']['modules_dir']}/#{format('%02d', new_resource.module_priority)}-#{new_resource.module_name}.conf" do
      action :delete
      notifies :reload, 'nginx_service[default]', :delayed
    end
  end

  # Delete module configuration file
  file new_resource.module_config_file do
    action :delete
    notifies :reload, 'nginx_service[default]', :delayed
  end
end
