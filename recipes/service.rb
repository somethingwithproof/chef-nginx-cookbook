#
# Cookbook:: nginx
# Recipe:: service
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

# Configure and start nginx service
nginx_service 'default' do
  service_name node['nginx']['service_name']
  # Define custom restart/reload commands if needed
  supports restart: true, reload: true, status: true
  action [:enable, :start]
end
