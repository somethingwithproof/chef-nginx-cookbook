#
# Cookbook:: nginx
# Attributes:: telemetry
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

# Telemetry general settings
default['nginx']['telemetry']['enabled'] = false
default['nginx']['telemetry']['status_enabled'] = true
default['nginx']['telemetry']['status_port'] = 8080
default['nginx']['telemetry']['status_allow_ips'] = ['127.0.0.1', '::1']

# Prometheus settings
default['nginx']['telemetry']['prometheus']['enabled'] = false
default['nginx']['telemetry']['prometheus']['exporter_version'] = '0.11.0'
default['nginx']['telemetry']['prometheus']['exporter_url'] = "https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v#{node['nginx']['telemetry']['prometheus']['exporter_version']}/nginx-prometheus-exporter_#{node['nginx']['telemetry']['prometheus']['exporter_version']}_linux_amd64.tar.gz"
default['nginx']['telemetry']['prometheus']['exporter_checksum'] = nil # Set in wrapper cookbook
default['nginx']['telemetry']['prometheus']['exporter_binary'] = '/usr/local/bin/nginx-prometheus-exporter'
default['nginx']['telemetry']['prometheus']['port'] = 9113
default['nginx']['telemetry']['prometheus']['metrics'] = %w(connections requests http)
default['nginx']['telemetry']['prometheus']['scrape_uri'] = 'http://localhost/nginx_status'
default['nginx']['telemetry']['prometheus']['allow_ips'] = ['127.0.0.1', '::1']
default['nginx']['telemetry']['prometheus']['user'] = 'prometheus'
default['nginx']['telemetry']['prometheus']['group'] = 'prometheus'

# Grafana settings
default['nginx']['telemetry']['grafana']['enabled'] = false
default['nginx']['telemetry']['grafana']['url'] = 'http://localhost:3000'
default['nginx']['telemetry']['grafana']['datasource'] = 'Prometheus'
default['nginx']['telemetry']['grafana']['api_key'] = nil # Set in wrapper cookbook
default['nginx']['telemetry']['grafana']['dashboard_id'] = 11280 # NGINX Dashboard by nginxinc
default['nginx']['telemetry']['grafana']['dashboard_revision'] = 1

# Logging settings related to telemetry
default['nginx']['telemetry']['json_logging_enabled'] = false
default['nginx']['telemetry']['json_log_format'] = 'escape=json'
default['nginx']['telemetry']['detailed_logging_enabled'] = false
default['nginx']['telemetry']['detailed_log_format'] = '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for" $request_time $upstream_response_time $pipe $upstream_cache_status $connection $connection_requests'
