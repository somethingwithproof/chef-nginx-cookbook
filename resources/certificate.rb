# frozen_string_literal: true

unified_mode true

provides :nginx_certificate

description 'Manages SSL/TLS certificates for nginx, including Let\'s Encrypt automation'

property :domain, String,
         name_property: true,
         description: 'Primary domain for the certificate'

property :alt_names, Array,
         default: [],
         description: 'Subject Alternative Names (additional domains)'

property :email, String,
         required: true,
         description: 'Email address for certificate notifications'

property :webroot, String,
         default: '/var/www/html',
         description: 'Webroot path for HTTP-01 challenge'

property :cert_provider, String,
         equal_to: %w(letsencrypt self_signed manual),
         default: 'letsencrypt',
         description: 'Certificate provider'

property :staging, [true, false],
         default: false,
         description: 'Use Let\'s Encrypt staging server (for testing)'

property :key_size, Integer,
         default: 4096,
         description: 'RSA key size in bits'

property :renew_before_days, Integer,
         default: 30,
         description: 'Days before expiry to attempt renewal'

property :certificate_path, String,
         default: lazy { "/etc/letsencrypt/live/#{domain}/fullchain.pem" },
         description: 'Path to certificate file'

property :key_path, String,
         default: lazy { "/etc/letsencrypt/live/#{domain}/privkey.pem" },
         description: 'Path to private key file'

property :reload_nginx, [true, false],
         default: true,
         description: 'Reload nginx after certificate changes'

action :create do
  case new_resource.cert_provider
  when 'letsencrypt'
    install_certbot
    request_letsencrypt_certificate
    setup_renewal_timer
  when 'self_signed'
    create_self_signed_certificate
  when 'manual'
    # Manual certificates are managed externally
    log "Manual certificate for #{new_resource.domain} - ensure files exist at #{new_resource.certificate_path}" do
      level :info
    end
  end
end

action :renew do
  execute "certbot_renew_#{new_resource.domain}" do
    command "certbot renew --cert-name #{new_resource.domain} --quiet"
    only_if { new_resource.cert_provider == 'letsencrypt' }
    notifies :reload, 'service[nginx]', :delayed if new_resource.reload_nginx
  end
end

action :revoke do
  execute "certbot_revoke_#{new_resource.domain}" do
    command "certbot revoke --cert-name #{new_resource.domain} --non-interactive"
    only_if { new_resource.cert_provider == 'letsencrypt' }
    only_if { ::File.exist?(new_resource.certificate_path) }
  end
end

action :delete do
  execute "certbot_delete_#{new_resource.domain}" do
    command "certbot delete --cert-name #{new_resource.domain} --non-interactive"
    only_if { new_resource.cert_provider == 'letsencrypt' }
    only_if { ::File.exist?(new_resource.certificate_path) }
  end

  # Delete self-signed certificates
  if new_resource.cert_provider == 'self_signed'
    file new_resource.certificate_path do
      action :delete
    end

    file new_resource.key_path do
      action :delete
    end
  end
end

action_class do
  def install_certbot
    case node['platform_family']
    when 'debian'
      package 'certbot' do
        action :install
      end

      package 'python3-certbot-nginx' do
        action :install
      end
    when 'rhel', 'fedora', 'amazon'
      # EPEL is required for certbot on RHEL
      include_recipe 'yum-epel::default' if platform_family?('rhel')

      package 'certbot' do
        action :install
      end

      package 'python3-certbot-nginx' do
        action :install
      end
    when 'freebsd'
      package 'py39-certbot' do
        action :install
      end

      package 'py39-certbot-nginx' do
        action :install
      end
    when 'mac_os_x'
      homebrew_package 'certbot' do
        action :install
      end
    end
  end

  def request_letsencrypt_certificate
    # Build the certbot command
    domains = [new_resource.domain] + new_resource.alt_names
    domain_args = domains.map { |d| "-d #{d}" }.join(' ')

    certbot_cmd = [
      'certbot certonly',
      '--nginx',
      '--non-interactive',
      '--agree-tos',
      "--email #{new_resource.email}",
      "--rsa-key-size #{new_resource.key_size}",
      domain_args,
    ]

    certbot_cmd << '--staging' if new_resource.staging

    execute "certbot_obtain_#{new_resource.domain}" do
      command certbot_cmd.join(' ')
      not_if { ::File.exist?(new_resource.certificate_path) }
      notifies :reload, 'service[nginx]', :delayed if new_resource.reload_nginx
    end
  end

  def setup_renewal_timer
    # Create systemd timer for automatic renewal
    if systemd?
      # Certbot typically installs its own timer, but we'll ensure it's enabled
      service 'certbot.timer' do
        action [:enable, :start]
        only_if { ::File.exist?('/lib/systemd/system/certbot.timer') }
      end

      # Create a custom renewal hook for nginx
      directory '/etc/letsencrypt/renewal-hooks/deploy' do
        recursive true
        mode '0755'
      end

      file '/etc/letsencrypt/renewal-hooks/deploy/nginx-reload.sh' do
        content <<~SCRIPT
          #!/bin/bash
          # Reload nginx after certificate renewal
          systemctl reload nginx || service nginx reload
        SCRIPT
        mode '0755'
      end
    end
  end

  def create_self_signed_certificate
    cert_dir = ::File.dirname(new_resource.certificate_path)
    key_dir = ::File.dirname(new_resource.key_path)

    directory cert_dir do
      recursive true
      mode '0755'
    end

    directory key_dir do
      recursive true
      mode '0700'
    end

    # Generate self-signed certificate
    domains = [new_resource.domain] + new_resource.alt_names
    san_extension = domains.map.with_index { |d, i| "DNS.#{i + 1}=#{d}" }.join(',')

    execute "generate_self_signed_#{new_resource.domain}" do
      command <<~CMD
        openssl req -x509 -nodes -days 365 \
          -newkey rsa:#{new_resource.key_size} \
          -keyout #{new_resource.key_path} \
          -out #{new_resource.certificate_path} \
          -subj "/CN=#{new_resource.domain}" \
          -addext "subjectAltName=#{san_extension}"
      CMD
      creates new_resource.certificate_path
      notifies :reload, 'service[nginx]', :delayed if new_resource.reload_nginx
    end

    file new_resource.key_path do
      mode '0600'
    end
  end
end
