# frozen_string_literal: true

unified_mode true

resource_name :nginx_upstream
provides :nginx_upstream

description 'Manages nginx upstream blocks for load balancing'

property :upstream_name, String,
         name_property: true,
         description: 'Name of the upstream block'

property :servers, Array,
         required: true,
         description: 'Array of backend servers (host:port or hash with options)'

property :lb_method, String,
         equal_to: %w(round_robin least_conn ip_hash random hash),
         default: 'round_robin',
         description: 'Load balancing method'

property :hash_key, String,
         description: 'Hash key for hash method (e.g., $request_uri)'

property :keepalive, Integer,
         default: 32,
         description: 'Number of keepalive connections to upstream'

property :keepalive_requests, Integer,
         default: 1000,
         description: 'Max requests per keepalive connection'

property :keepalive_timeout, String,
         default: '60s',
         description: 'Keepalive connection timeout'

property :fail_timeout, String,
         default: '10s',
         description: 'Time to consider server unavailable after max_fails'

property :max_fails, Integer,
         default: 3,
         description: 'Number of failed attempts to mark server unavailable'

property :zone, String,
         description: 'Shared memory zone for upstream state (for NGINX Plus or dynamic upstreams)'

property :zone_size, String,
         default: '64k',
         description: 'Size of shared memory zone'

property :health_check, Hash,
         default: {},
         description: 'Health check configuration (NGINX Plus only)'

property :sticky, Hash,
         default: {},
         description: 'Sticky session configuration'

property :conf_dir, String,
         default: lazy { node['nginx']['conf_dir'] },
         description: 'Nginx configuration directory'

action :create do
  # Create upstreams configuration directory
  directory "#{new_resource.conf_dir}/upstreams.d" do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  # Generate upstream configuration
  template "#{new_resource.conf_dir}/upstreams.d/#{new_resource.upstream_name}.conf" do
    source 'upstream.conf.erb'
    cookbook 'nginx'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      name: new_resource.upstream_name,
      servers: normalize_servers(new_resource.servers),
      method: new_resource.lb_method,
      hash_key: new_resource.hash_key,
      keepalive: new_resource.keepalive,
      keepalive_requests: new_resource.keepalive_requests,
      keepalive_timeout: new_resource.keepalive_timeout,
      zone: new_resource.zone,
      zone_size: new_resource.zone_size,
      sticky: new_resource.sticky,
      health_check: new_resource.health_check
    )
    notifies :reload, 'service[nginx]', :delayed
  end
end

action :delete do
  file "#{new_resource.conf_dir}/upstreams.d/#{new_resource.upstream_name}.conf" do
    action :delete
    notifies :reload, 'service[nginx]', :delayed
  end
end

action_class do
  # Normalize server entries to consistent format
  def normalize_servers(servers)
    servers.map do |server|
      case server
      when String
        # Simple "host:port" format
        {
          'address' => server,
          'weight' => 1,
          'max_fails' => new_resource.max_fails,
          'fail_timeout' => new_resource.fail_timeout,
        }
      when Hash
        # Full configuration hash
        {
          'address' => server['address'] || server[:address],
          'weight' => server['weight'] || server[:weight] || 1,
          'max_fails' => server['max_fails'] || server[:max_fails] || new_resource.max_fails,
          'fail_timeout' => server['fail_timeout'] || server[:fail_timeout] || new_resource.fail_timeout,
          'backup' => server['backup'] || server[:backup] || false,
          'down' => server['down'] || server[:down] || false,
          'max_conns' => server['max_conns'] || server[:max_conns],
          'slow_start' => server['slow_start'] || server[:slow_start],
        }.compact
      else
        raise "Invalid server specification: #{server.inspect}"
      end
    end
  end
end
