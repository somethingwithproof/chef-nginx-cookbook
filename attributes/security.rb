#
# Cookbook:: nginx
# Attributes:: security
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

# Basic security settings
default['nginx']['security']['server_tokens'] = 'off'
default['nginx']['security']['server_signature'] = 'off'
default['nginx']['security']['client_body_buffer_size'] = '16k'
default['nginx']['security']['client_max_body_size'] = '10m'
default['nginx']['security']['hide_headers'] = [
  'X-Powered-By',
  'Server',
]
default['nginx']['security']['add_headers'] = {
  'X-Content-Type-Options' => 'nosniff',
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '1; mode=block',
}

# SSL Settings
default['nginx']['security']['ssl_enabled'] = true
default['nginx']['security']['ssl_protocols'] = 'TLSv1.2 TLSv1.3'
default['nginx']['security']['ssl_ciphers'] = 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384'
default['nginx']['security']['ssl_prefer_server_ciphers'] = 'on'
default['nginx']['security']['ssl_session_cache'] = 'shared:SSL:10m'
default['nginx']['security']['ssl_session_timeout'] = '1d'
default['nginx']['security']['ssl_stapling'] = 'on'
default['nginx']['security']['ssl_stapling_verify'] = 'on'
default['nginx']['security']['ssl_trusted_certificate'] = nil # Set in wrapper cookbook
default['nginx']['security']['dhparam_file'] = nil # Set in wrapper cookbook

# Security Modules
default['nginx']['security']['enable_modsecurity'] = false
default['nginx']['security']['modsecurity_rules'] = 'include /etc/nginx/modsecurity/modsecurity.conf'
default['nginx']['security']['modsecurity_crs_enabled'] = false
default['nginx']['security']['modsecurity_crs_rules_file'] = '/etc/nginx/modsecurity/crs-setup.conf'

# System Security Settings
default['nginx']['security']['selinux_enabled'] = true
default['nginx']['security']['apparmor_enabled'] = true

# Rate Limiting
default['nginx']['security']['rate_limiting_enabled'] = false
default['nginx']['security']['rate_limiting_zone_name'] = 'limit'
default['nginx']['security']['rate_limiting_zone_size'] = '10m'
default['nginx']['security']['rate_limiting_max_conns'] = '10r/s'
