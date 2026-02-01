# frozen_string_literal: true

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

# Skip if telemetry is not enabled
return unless node['nginx']['telemetry']['enabled']

# Enable Prometheus exporter if enabled
if node['nginx']['telemetry']['prometheus']['enabled']
  # Ensure status module is available for metrics
  node.default['nginx']['monitoring']['status_path'] = node['nginx']['telemetry']['prometheus']['scrape_uri']
  node.default['nginx']['monitoring']['restricted_access'] = true
  node.default['nginx']['monitoring']['allowed_ips'] = node['nginx']['telemetry']['prometheus']['allow_ips']

  # Install nginx-prometheus-exporter (current stable version configurable via attributes)
  nginx_exporter_version = node['nginx']['telemetry']['prometheus']['exporter_version']
  nginx_exporter_checksum = node['nginx']['telemetry']['prometheus']['exporter_checksum']

  remote_file "#{Chef::Config[:file_cache_path]}/nginx-prometheus-exporter.tar.gz" do
    source "https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v#{nginx_exporter_version}/nginx-prometheus-exporter_#{nginx_exporter_version}_linux_amd64.tar.gz"
    checksum nginx_exporter_checksum if nginx_exporter_checksum
    action :create
    notifies :run, 'bash[extract_nginx_prometheus_exporter]', :immediately
  end

  bash 'extract_nginx_prometheus_exporter' do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
      set -e
      tar xzf nginx-prometheus-exporter.tar.gz
      cp nginx-prometheus-exporter /usr/local/bin/
      chmod +x /usr/local/bin/nginx-prometheus-exporter
    EOH
    action :nothing
  end

  # Create systemd service
  template '/etc/systemd/system/nginx-prometheus-exporter.service' do
    source 'nginx-prometheus-exporter.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      scrape_uri: "http://localhost#{node['nginx']['telemetry']['prometheus']['scrape_uri']}",
      telemetry_path: node['nginx']['telemetry']['prometheus']['telemetry_path']
    )
    notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  end

  execute 'systemctl-daemon-reload' do
    command 'systemctl daemon-reload'
    action :nothing
  end

  # Enable and start service
  service 'nginx-prometheus-exporter' do
    action %i(enable start)
  end
end

# Configure Grafana dashboard if enabled
if node['nginx']['telemetry']['grafana']['enabled'] && node['nginx']['telemetry']['prometheus']['enabled']
  require 'json'

  # Create Grafana dashboard JSON
  nginx_dashboard = {
    'dashboard' => {
      'id' => nil,
      'title' => 'Nginx Metrics',
      'tags' => %w(nginx prometheus web),
      'timezone' => 'browser',
      'schemaVersion' => 16,
      'version' => 1,
      'refresh' => '30s',
      'panels' => [
        {
          'type' => 'graph',
          'title' => 'Connections',
          'gridPos' => { 'x' => 0, 'y' => 0, 'w' => 12, 'h' => 8 },
          'id' => 1,
          'targets' => [
            {
              'expr' => 'nginx_connections_active',
              'refId' => 'A',
              'legendFormat' => 'Active Connections',
            },
            {
              'expr' => 'nginx_connections_reading',
              'refId' => 'B',
              'legendFormat' => 'Reading',
            },
            {
              'expr' => 'nginx_connections_writing',
              'refId' => 'C',
              'legendFormat' => 'Writing',
            },
            {
              'expr' => 'nginx_connections_waiting',
              'refId' => 'D',
              'legendFormat' => 'Waiting',
            },
          ],
        },
        {
          'type' => 'graph',
          'title' => 'Requests',
          'gridPos' => { 'x' => 12, 'y' => 0, 'w' => 12, 'h' => 8 },
          'id' => 2,
          'targets' => [
            {
              'expr' => 'rate(nginx_http_requests_total[5m])',
              'refId' => 'A',
              'legendFormat' => 'Requests/s',
            },
          ],
        },
      ],
      'templating' => {
        'list' => [],
      },
      'time' => {
        'from' => 'now-6h',
        'to' => 'now',
      },
      'timepicker' => {
        'refresh_intervals' => %w(5s 10s 30s 1m 5m 15m 30m 1h 2h 1d),
      },
    },
    'folderId' => 0,
    'folderUid' => '',
    'message' => 'Nginx dashboard created by Chef',
    'overwrite' => true,
  }

  # Write dashboard JSON to file
  file '/etc/nginx/grafana-dashboard.json' do
    content JSON.pretty_generate(nginx_dashboard)
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  # Upload to Grafana if API key provided
  if node['nginx']['telemetry']['grafana']['api_key']
    # Required gems for HTTP requests (pin version for reproducible builds)
    chef_gem 'httparty' do
      version '~> 0.21.0'
      compile_time true
    end

    require 'httparty'

    ruby_block 'upload_grafana_dashboard' do
      block do
        # Prepare request
        url = "#{node['nginx']['telemetry']['grafana']['url']}/api/dashboards/db"
        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{node['nginx']['telemetry']['grafana']['api_key']}",
        }

        # Send request
        begin
          response = HTTParty.post(url,
                                   body: nginx_dashboard.to_json,
                                   headers: headers)

          if response.code == 200
            Chef.logger.info('Grafana dashboard created successfully')
          else
            Chef.logger.error("Failed to create Grafana dashboard: #{response.body}")
          end
        rescue StandardError => e
          Chef.logger.error("Error communicating with Grafana API: #{e.message}")
        end
      end
      action :run
    end
  end
end
