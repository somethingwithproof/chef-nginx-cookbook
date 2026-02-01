# frozen_string_literal: true

#
# Cookbook:: nginx
# Recipe:: stream
#
# Copyright:: 2023-2026, Thomas Vincent
# License:: Apache-2.0
#
# Configures nginx stream (TCP/UDP) proxy functionality

# Ensure stream module is enabled (compiled with --with-stream)
# Note: This requires nginx to be compiled with stream support

# Create stream configuration directory
directory "#{node['nginx']['conf_dir']}/stream.d" do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

# Create main stream configuration
template "#{node['nginx']['conf_dir']}/stream.conf" do
  source 'stream.conf.erb'
  cookbook 'nginx'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    stream_dir: "#{node['nginx']['conf_dir']}/stream.d"
  )
  notifies :reload, 'service[nginx]', :delayed
end

# Create stream upstreams from attributes
node['nginx']['stream']['upstreams'].each do |name, config|
  nginx_stream_upstream name do
    servers config['servers']
    method config['method'] || 'round_robin'
    hash_key config['hash_key'] if config['hash_key']
    fail_timeout config['fail_timeout'] || '10s'
    max_fails config['max_fails'] || 3
    zone config['zone'] if config['zone']
    zone_size config['zone_size'] || '64k'
    action :create
  end
end

# Create stream server blocks from attributes
node['nginx']['stream']['servers'].each do |server|
  template "#{node['nginx']['conf_dir']}/stream.d/server_#{server['name']}.conf" do
    source 'stream_server.conf.erb'
    cookbook 'nginx'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      name: server['name'],
      listen_port: server['listen'],
      protocol: server['protocol'] || 'tcp',
      upstream: server['upstream'],
      proxy_timeout: server['proxy_timeout'] || '10m',
      proxy_connect_timeout: server['proxy_connect_timeout'] || '60s',
      proxy_protocol: server['proxy_protocol'] || false,
      ssl: server['ssl'] || false,
      ssl_certificate: server['ssl_certificate'],
      ssl_certificate_key: server['ssl_certificate_key'],
      ssl_protocols: server['ssl_protocols'] || 'TLSv1.2 TLSv1.3',
      ssl_ciphers: server['ssl_ciphers']
    )
    notifies :reload, 'service[nginx]', :delayed
  end
end
