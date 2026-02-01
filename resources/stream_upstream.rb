# frozen_string_literal: true

unified_mode true

resource_name :nginx_stream_upstream
provides :nginx_stream_upstream

description 'Manages nginx stream (TCP/UDP) upstream blocks'

property :upstream_name, String,
         name_property: true,
         description: 'Name of the stream upstream block'

property :servers, Array,
         required: true,
         description: 'Array of backend servers (host:port or hash with options)'

property :lb_method, String,
         equal_to: %w(round_robin least_conn hash random),
         default: 'round_robin',
         description: 'Load balancing method'

property :hash_key, String,
         description: 'Hash key for hash method (e.g., $remote_addr)'

property :fail_timeout, String,
         default: '10s',
         description: 'Time to consider server unavailable after max_fails'

property :max_fails, Integer,
         default: 3,
         description: 'Number of failed attempts to mark server unavailable'

property :zone, String,
         description: 'Shared memory zone for upstream state'

property :zone_size, String,
         default: '64k',
         description: 'Size of shared memory zone'

property :conf_dir, String,
         default: lazy { node['nginx']['conf_dir'] },
         description: 'Nginx configuration directory'

action :create do
  # Create stream upstreams configuration directory
  directory "#{new_resource.conf_dir}/stream.d" do
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
  end

  # Generate stream upstream configuration
  template "#{new_resource.conf_dir}/stream.d/upstream_#{new_resource.upstream_name}.conf" do
    source 'stream_upstream.conf.erb'
    cookbook 'nginx'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      name: new_resource.upstream_name,
      servers: normalize_servers(new_resource.servers),
      method: new_resource.lb_method,
      hash_key: new_resource.hash_key,
      zone: new_resource.zone,
      zone_size: new_resource.zone_size
    )
    notifies :reload, 'service[nginx]', :delayed
  end
end

action :delete do
  file "#{new_resource.conf_dir}/stream.d/upstream_#{new_resource.upstream_name}.conf" do
    action :delete
    notifies :reload, 'service[nginx]', :delayed
  end
end

action_class do
  def normalize_servers(servers)
    servers.map do |server|
      case server
      when String
        {
          'address' => server,
          'weight' => 1,
          'max_fails' => new_resource.max_fails,
          'fail_timeout' => new_resource.fail_timeout,
        }
      when Hash
        {
          'address' => server['address'] || server[:address],
          'weight' => server['weight'] || server[:weight] || 1,
          'max_fails' => server['max_fails'] || server[:max_fails] || new_resource.max_fails,
          'fail_timeout' => server['fail_timeout'] || server[:fail_timeout] || new_resource.fail_timeout,
          'backup' => server['backup'] || server[:backup] || false,
          'down' => server['down'] || server[:down] || false,
          'max_conns' => server['max_conns'] || server[:max_conns],
        }.compact
      else
        raise "Invalid server specification: #{server.inspect}"
      end
    end
  end
end
