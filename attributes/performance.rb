#
# Cookbook:: nginx
# Attributes:: performance
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

# Worker settings
default['nginx']['performance']['worker_processes'] = 'auto' # Can be a number or 'auto'
default['nginx']['performance']['worker_connections'] = 1024
default['nginx']['performance']['worker_rlimit_nofile'] = 4096
default['nginx']['performance']['multi_accept'] = 'on'

# Timeouts
default['nginx']['performance']['keepalive_timeout'] = 65
default['nginx']['performance']['keepalive_requests'] = 100
default['nginx']['performance']['client_body_timeout'] = 60
default['nginx']['performance']['client_header_timeout'] = 60
default['nginx']['performance']['send_timeout'] = 60

# Buffers
default['nginx']['performance']['client_body_buffer_size'] = '128k'
default['nginx']['performance']['client_header_buffer_size'] = '1k'
default['nginx']['performance']['client_max_body_size'] = '10m'
default['nginx']['performance']['large_client_header_buffers'] = '4 8k'
default['nginx']['performance']['output_buffers'] = '1 32k'
default['nginx']['performance']['postpone_output'] = 1460

# File operations
default['nginx']['performance']['sendfile'] = 'on'
default['nginx']['performance']['tcp_nopush'] = 'on'
default['nginx']['performance']['tcp_nodelay'] = 'on'

# Cache settings
default['nginx']['performance']['open_file_cache'] = 'max=1000 inactive=20s'
default['nginx']['performance']['open_file_cache_valid'] = '30s'
default['nginx']['performance']['open_file_cache_min_uses'] = 2
default['nginx']['performance']['open_file_cache_errors'] = 'on'

# Compression
default['nginx']['performance']['gzip'] = 'on'
default['nginx']['performance']['gzip_comp_level'] = 2
default['nginx']['performance']['gzip_min_length'] = 1000
default['nginx']['performance']['gzip_proxied'] = 'expired no-cache no-store private auth'
default['nginx']['performance']['gzip_types'] = [
  'text/plain',
  'text/css',
  'text/xml',
  'text/javascript',
  'application/javascript',
  'application/x-javascript',
  'application/json',
  'application/xml',
  'application/xml+rss',
  'application/vnd.ms-fontobject',
  'font/truetype',
  'font/opentype',
  'image/svg+xml',
]
default['nginx']['performance']['gzip_vary'] = 'on'
default['nginx']['performance']['gzip_disable'] = 'msie6'

# Dynamic TLS record sizing
default['nginx']['performance']['ssl_buffer_size'] = '4k'
default['nginx']['performance']['ssl_dynamic_record_size'] = true
