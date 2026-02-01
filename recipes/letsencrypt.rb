# frozen_string_literal: true

#
# Cookbook:: nginx
# Recipe:: letsencrypt
#
# Copyright:: 2023-2026, Thomas Vincent
# License:: Apache-2.0
#

# Install certbot and nginx plugin
case node['platform_family']
when 'debian'
  package %w(certbot python3-certbot-nginx) do
    action :install
  end
when 'rhel', 'fedora', 'amazon'
  include_recipe 'yum-epel::default' if platform_family?('rhel')

  package %w(certbot python3-certbot-nginx) do
    action :install
  end
when 'freebsd'
  package %w(py39-certbot py39-certbot-nginx) do
    action :install
  end
when 'mac_os_x'
  homebrew_package 'certbot' do
    action :install
  end
end

# Ensure webroot exists for ACME challenges
directory node['nginx']['letsencrypt']['webroot'] do
  recursive true
  mode '0755'
end

# Create ACME challenge directory
directory "#{node['nginx']['letsencrypt']['webroot']}/.well-known/acme-challenge" do
  recursive true
  mode '0755'
end

# Configure nginx for ACME challenges
template "#{node['nginx']['conf_dir']}/conf.d/letsencrypt.conf" do
  source 'letsencrypt.conf.erb'
  cookbook 'nginx'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    webroot: node['nginx']['letsencrypt']['webroot']
  )
  notifies :reload, 'service[nginx]', :delayed
end

# Set up automatic renewal
if systemd?
  # Enable certbot timer if it exists
  service 'certbot.timer' do
    action [:enable, :start]
    only_if { ::File.exist?('/lib/systemd/system/certbot.timer') }
  end

  # Create nginx reload hook for successful renewals
  directory '/etc/letsencrypt/renewal-hooks/deploy' do
    recursive true
    mode '0755'
  end

  file '/etc/letsencrypt/renewal-hooks/deploy/01-nginx-reload' do
    content <<~SCRIPT
      #!/bin/bash
      # Reload nginx after successful certificate renewal
      /bin/systemctl reload nginx.service 2>/dev/null || /usr/sbin/service nginx reload 2>/dev/null || true
    SCRIPT
    mode '0755'
  end
else
  # Create cron job for renewal on non-systemd systems
  cron 'certbot_renew' do
    minute '0'
    hour '3'
    day '*'
    month '*'
    weekday '*'
    command '/usr/bin/certbot renew --quiet --deploy-hook "nginx -s reload"'
    user 'root'
  end
end

# Request certificates for configured domains
node['nginx']['letsencrypt']['domains'].each do |domain_config|
  nginx_certificate domain_config['domain'] do
    alt_names domain_config['alt_names'] || []
    email domain_config['email'] || node['nginx']['letsencrypt']['email']
    webroot node['nginx']['letsencrypt']['webroot']
    staging node['nginx']['letsencrypt']['staging']
    provider 'letsencrypt'
    action :create
    only_if { domain_config['enabled'] != false }
  end
end
