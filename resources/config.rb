#
# Cookbook:: nginx
# Resource:: config
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

property :config_name, String, name_property: true
property :source, String, required: true
property :cookbook, String, default: 'nginx'
property :variables, Hash, default: {}
property :conf_dir, String, default: lazy { node['nginx']['conf_dir'] }
property :template_location, String, default: 'conf.d'

action :create do
  # Ensure the conf.d directory exists
  directory "#{new_resource.conf_dir}/#{new_resource.template_location}" do
    owner 'root'
    group node['root_group']
    mode '0755'
    recursive true
  end

  template "#{new_resource.conf_dir}/#{new_resource.template_location}/#{new_resource.config_name}.conf" do
    source new_resource.source
    cookbook new_resource.cookbook
    variables new_resource.variables
    owner 'root'
    group node['root_group']
    mode '0644'
    action :create
  end
end

action :delete do
  file "#{new_resource.conf_dir}/#{new_resource.template_location}/#{new_resource.config_name}.conf" do
    action :delete
  end
end
