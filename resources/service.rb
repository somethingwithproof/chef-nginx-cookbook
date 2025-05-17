#
# Cookbook:: nginx
# Resource:: service
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

property :service_name, String, default: lazy { node['nginx']['service_name'] }
property :restart_command, [String, nil], default: nil
property :reload_command, [String, nil], default: nil
property :supports, Hash, default: { restart: true, reload: true, status: true }

action :start do
  service new_resource.service_name do
    supports new_resource.supports
    action :start
  end
end

action :stop do
  service new_resource.service_name do
    supports new_resource.supports
    action :stop
  end
end

action :restart do
  service new_resource.service_name do
    supports new_resource.supports
    restart_command new_resource.restart_command if new_resource.restart_command
    action :restart
  end
end

action :reload do
  service new_resource.service_name do
    supports new_resource.supports
    reload_command new_resource.reload_command if new_resource.reload_command
    action :reload
  end
end

action :enable do
  service new_resource.service_name do
    supports new_resource.supports
    action :enable
  end
end

action :disable do
  service new_resource.service_name do
    supports new_resource.supports
    action :disable
  end
end

# Composite actions
action_class do
  def define_resource_requirements
    # Check if the service exists
    requirements.assert(:start, :restart, :reload, :enable) do |a|
      a.assertion { ::File.exist?('/lib/systemd/system/nginx.service') || ::File.exist?('/usr/lib/systemd/system/nginx.service') || ::File.exist?('/etc/init.d/nginx') }
      a.failure_message('Nginx service not found. Please ensure nginx is installed.')
    end
  end
end

action :configure do
  service new_resource.service_name do
    supports new_resource.supports
    restart_command new_resource.restart_command if new_resource.restart_command
    reload_command new_resource.reload_command if new_resource.reload_command
    action :nothing
  end
end

action_class do
  def service_alive?
    cmd = Mixlib::ShellOut.new("pidof #{new_resource.service_name}")
    cmd.run_command
    !cmd.error?
  end
end
