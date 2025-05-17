#
# Cookbook:: nginx
# Recipe:: telemetry
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

# Skip if telemetry is not enabled
return unless node['nginx']['telemetry']['enabled']

# Make sure status module is configured for telemetry
nginx_config 'status' do
  source 'status.conf.erb'
  variables(
    status_path: '/nginx_status',
    allowed_ips: node['nginx']['telemetry']['status_allow_ips']
  )
  action :create
  notifies :reload, 'nginx_service[default]', :delayed
end

# Install and configure JSON logging if enabled
if node['nginx']['telemetry']['json_logging_enabled']
  nginx_config 'json_logging' do
    source 'json_logging.conf.erb'
    variables(
      log_format: node['nginx']['telemetry']['json_log_format']
    )
    action :create
    notifies :reload, 'nginx_service[default]', :delayed
  end
end

# Install and configure detailed logging if enabled
if node['nginx']['telemetry']['detailed_logging_enabled']
  nginx_config 'detailed_logging' do
    source 'detailed_logging.conf.erb'
    variables(
      log_format: node['nginx']['telemetry']['detailed_log_format']
    )
    action :create
    notifies :reload, 'nginx_service[default]', :delayed
  end
end

# Configure Prometheus exporter if enabled
if node['nginx']['telemetry']['prometheus']['enabled']
  # Download and install the Prometheus exporter
  remote_file "#{Chef::Config[:file_cache_path]}/nginx-prometheus-exporter.tar.gz" do
    source node['nginx']['telemetry']['prometheus']['exporter_url']
    checksum node['nginx']['telemetry']['prometheus']['exporter_checksum'] if node['nginx']['telemetry']['prometheus']['exporter_checksum']
    notifies :run, 'bash[install_nginx_prometheus_exporter]', :immediately
  end

  bash 'install_nginx_prometheus_exporter' do
    cwd Chef::Config[:file_cache_path]
    code <<~EOH
      tar -xzf nginx-prometheus-exporter.tar.gz
      mv nginx-prometheus-exporter #{node['nginx']['telemetry']['prometheus']['exporter_binary']}
      chmod +x #{node['nginx']['telemetry']['prometheus']['exporter_binary']}
    EOH
    action :nothing
  end

  # Create system user/group for the exporter
  group node['nginx']['telemetry']['prometheus']['group'] do
    system true
    not_if "getent group #{node['nginx']['telemetry']['prometheus']['group']}"
  end

  user node['nginx']['telemetry']['prometheus']['user'] do
    system true
    group node['nginx']['telemetry']['prometheus']['group']
    shell '/sbin/nologin'
    not_if "getent passwd #{node['nginx']['telemetry']['prometheus']['user']}"
  end

  # Create systemd service file
  template '/lib/systemd/system/nginx-prometheus-exporter.service' do
    source 'nginx-prometheus-exporter.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      user: node['nginx']['telemetry']['prometheus']['user'],
      group: node['nginx']['telemetry']['prometheus']['group'],
      binary_path: node['nginx']['telemetry']['prometheus']['exporter_binary'],
      scrape_uri: "http://localhost/nginx_status",
      listen_address: ":#{node['nginx']['telemetry']['prometheus']['port']}",
      metrics: node['nginx']['telemetry']['prometheus']['metrics'].join(',')
    )
    notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  end

  execute 'systemctl-daemon-reload' do
    command 'systemctl daemon-reload'
    action :nothing
  end

  # Start and enable the exporter service
  service 'nginx-prometheus-exporter' do
    action [:enable, :start]
  end
end

# Configure Grafana integration if enabled
if node['nginx']['telemetry']['grafana']['enabled'] && node['nginx']['telemetry']['prometheus']['enabled']
  # Check if we have the required gem for Grafana API integration
  chef_gem 'httparty' do
    action :install
    compile_time false
  end

  # Only attempt to install dashboard if API key is provided
  if node['nginx']['telemetry']['grafana']['api_key']
    ruby_block 'install_grafana_dashboard' do
      block do
        require 'httparty'
        require 'json'

        # Prepare dashboard payload
        url = "#{node['nginx']['telemetry']['grafana']['url']}/api/dashboards/db"
        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{node['nginx']['telemetry']['grafana']['api_key']}"
        }

        # Get dashboard JSON - either import from Grafana.com or use a simpler local version
        if node['nginx']['telemetry']['grafana']['dashboard_id']
          # Get dashboard from Grafana.com
          dashboard_url = "https://grafana.com/api/dashboards/#{node['nginx']['telemetry']['grafana']['dashboard_id']}/revisions/#{node['nginx']['telemetry']['grafana']['dashboard_revision']}/download"
          response = HTTParty.get(dashboard_url)
          
          if response.code == 200
            dashboard_json = response.body
            # Update datasource
            dashboard = JSON.parse(dashboard_json)
            dashboard['dashboard']['__inputs'].each do |input|
              if input['name'] == 'DS_PROMETHEUS'
                input['value'] = node['nginx']['telemetry']['grafana']['datasource']
              end
            end
            payload = {
              dashboard: dashboard['dashboard'],
              overwrite: true,
              inputs: dashboard['__inputs']
            }
          else
            Chef::Log.error("Failed to download Grafana dashboard: #{response.code}")
            return
          end
        else
          # Simple local dashboard
          payload = {
            dashboard: {
              id: nil,
              title: 'Nginx Metrics',
              tags: ['nginx', 'prometheus', 'web'],
              timezone: 'browser',
              schemaVersion: 16,
              version: 1,
              refresh: '30s',
              panels: [
                {
                  type: 'graph',
                  title: 'Active Connections',
                  gridPos: { x: 0, y: 0, w: 12, h: 8 },
                  id: 1,
                  targets: [
                    {
                      expr: 'nginx_connections_active',
                      refId: 'A',
                      legendFormat: 'Active Connections'
                    }
                  ]
                },
                {
                  type: 'graph',
                  title: 'Requests per second',
                  gridPos: { x: 12, y: 0, w: 12, h: 8 },
                  id: 2,
                  targets: [
                    {
                      expr: 'rate(nginx_http_requests_total[5m])',
                      refId: 'A',
                      legendFormat: 'Requests/s'
                    }
                  ]
                }
              ]
            },
            overwrite: true
          }
        end

        # Submit dashboard to Grafana
        response = HTTParty.post(url, 
          body: payload.to_json,
          headers: headers
        )

        if response.code == 200
          Chef::Log.info("Grafana dashboard installed successfully")
        else
          Chef::Log.error("Failed to install Grafana dashboard: #{response.code} - #{response.body}")
        end
      end
      action :run
    end
  end
end
