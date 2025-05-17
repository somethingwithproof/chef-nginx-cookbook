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
#

# Install nginx using the nginx_install resource
nginx_install 'default' do
  version node['nginx']['version']
  install_method node['nginx']['install_method']
  package_name node['nginx']['package_name']
  source_url node['nginx']['source']['url']
  # Set source_checksum if defined in a wrapper cookbook
  source_checksum node['nginx']['source']['checksum'] if node['nginx'].attribute?('source') && node['nginx']['source'].attribute?('checksum')
  configure_flags node['nginx']['source']['configure_flags'] if node['nginx']['install_method'] == 'source'
  use_official_repo node['nginx']['repo']['use_official_repo']
  repo_url node['nginx']['repo']['url']
  repo_key node['nginx']['repo']['key']
  user node['nginx']['user']
  group node['nginx']['group']
  action :install
end
