# copyright: 2023, Thomas Vincent

title 'NGINX Security Configuration'

# Path to Nginx configuration files
_ = input('nginx_conf_path', value: '/etc/nginx/nginx.conf', description: 'Path to NGINX configuration file')
ssl_conf_path = input('ssl_conf_path', value: '/etc/nginx/conf.d/ssl.conf', description: 'Path to SSL configuration file')
security_conf_path = input('security_conf_path', value: '/etc/nginx/conf.d/security.conf', description: 'Path to security configuration file')

control 'nginx-01' do
  impact 1.0
  title 'NGINX server_tokens directive must be off'
  desc 'The NGINX server_tokens directive should be set to off to prevent the server from revealing its version number.'

  describe nginx_conf do
    its('server_tokens') { should eq 'off' }
  end

  describe file(security_conf_path) do
    its('content') { should match /^\s*server_tokens\s+off;/ }
  end
end

control 'nginx-02' do
  impact 1.0
  title 'NGINX must have modern SSL protocols configured'
  desc 'NGINX should be configured to only use modern SSL protocols (TLSv1.2, TLSv1.3) and disable older protocols.'

  describe file(ssl_conf_path) do
    its('content') { should match /^\s*ssl_protocols\s+(?!.*SSLv2)(?!.*SSLv3)(?!.*TLSv1\.0)(?!.*TLSv1\.1).*TLSv1\.2.*/ }
  end
end

control 'nginx-03' do
  impact 1.0
  title 'NGINX must have strong cipher suites configured'
  desc 'NGINX should be configured with strong cipher suites to ensure secure communication.'

  describe file(ssl_conf_path) do
    its('content') { should match /^\s*ssl_ciphers\s+(?=.*ECDHE)(?!.*RC4)(?!.*MD5)(?!.*NULL).*/ }
  end
end

control 'nginx-04' do
  impact 1.0
  title 'NGINX must prefer server ciphers over client ciphers'
  desc 'NGINX should be configured to prefer server ciphers over client ciphers for better security.'

  describe file(ssl_conf_path) do
    its('content') { should match /^\s*ssl_prefer_server_ciphers\s+on;/ }
  end
end

control 'nginx-05' do
  impact 1.0
  title 'NGINX must have security headers configured'
  desc 'NGINX should include security headers in responses to mitigate common web vulnerabilities.'

  describe file(security_conf_path) do
    its('content') { should match /X-Content-Type-Options/ }
    its('content') { should match /X-Frame-Options/ }
    its('content') { should match /X-XSS-Protection/ }
  end
end

control 'nginx-06' do
  impact 1.0
  title 'NGINX must have client_max_body_size set'
  desc 'NGINX should have client_max_body_size directive set to limit request body size.'

  describe file(security_conf_path) do
    its('content') { should match /^\s*client_max_body_size\s+\d+[kKmMgG]?;/ }
  end
end

control 'nginx-07' do
  impact 0.5
  title 'NGINX should disable directory listing'
  desc 'NGINX should disable directory listing to prevent information disclosure.'

  describe file(security_conf_path) do
    its('content') { should match /^\s*autoindex\s+off;/ }
  end
end

control 'nginx-08' do
  impact 0.7
  title 'NGINX should have connection and request limits'
  desc 'NGINX should have connection and request rate limiting configured to prevent DoS attacks.'

  describe file(security_conf_path) do
    its('content') { should match /limit_conn_zone|limit_req_zone/ }
  end
end
