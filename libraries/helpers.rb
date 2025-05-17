#
# Cookbook:: nginx
# Library:: helpers
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

module Nginx
  module Cookbook
    module Helpers
      # Detects the platform family and returns appropriate paths
      def nginx_config_path
        case node['platform_family']
        when 'debian'
          '/etc/nginx'
        when 'rhel', 'amazon'
          '/etc/nginx'
        else
          '/etc/nginx'
        end
      end

      # Returns the correct user for the platform
      def nginx_user
        case node['platform_family']
        when 'debian'
          'www-data'
        when 'rhel', 'amazon'
          'nginx'
        else
          'nginx'
        end
      end

      # Returns the correct group for the platform
      def nginx_group
        case node['platform_family']
        when 'debian'
          'www-data'
        when 'rhel', 'amazon'
          'nginx'
        else
          'nginx'
        end
      end

      # Detects whether we are on a systemd-based system
      def systemd_based?
        ::File.exist?('/bin/systemctl') || ::File.exist?('/usr/bin/systemctl')
      end

      # Validates that a port is numeric and in a valid range
      def validate_port(port)
        port = port.to_i
        return port if port.between?(1, 65_535)

        raise ArgumentError, "Invalid port: #{port}, must be 1-65535"
      end

      # Validates that a path exists on disk
      def validate_path_exists(path, is_directory = false)
        path = path.to_s
        if is_directory
          return path if ::File.directory?(path)

          raise ArgumentError, "Invalid directory: #{path}, must exist"
        else
          return path if ::File.exist?(path)

          raise ArgumentError, "Invalid file: #{path}, must exist"
        end
      end

      # Generates a configuration content checksum
      def generate_config_checksum(config_content)
        require 'digest/md5'
        Digest::MD5.hexdigest(config_content)
      end

      # Helper for getting nginx process state
      def nginx_running?
        cmd = shell_out('pgrep nginx')
        cmd.exitstatus == 0
      end

      extend self
    end
  end
end

# Make the helper methods available everywhere
Chef::Recipe.include(Nginx::Cookbook::Helpers)
Chef::Resource.include(Nginx::Cookbook::Helpers)
