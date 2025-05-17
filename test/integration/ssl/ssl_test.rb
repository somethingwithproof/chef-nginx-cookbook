# InSpec test for recipe nginx::default with SSL configuration

describe port(443) do
  it { should be_listening }
  its('protocols') { should include 'tcp' }
  its('processes') { should include 'nginx' }
end

describe ssl(port: 443, host: 'localhost') do
  it { should be_enabled }
end

# Test for proper TLS protocols (no TLS 1.0/1.1)
describe command('echo | openssl s_client -connect localhost:443 -tls1 2>&1') do
  its('exit_status') { should_not eq 0 }
  its('stdout') { should match /no protocols available/ }
end

describe command('echo | openssl s_client -connect localhost:443 -tls1_1 2>&1') do
  its('exit_status') { should_not eq 0 }
  its('stdout') { should match /no protocols available/ }
end

# Test TLS 1.2 is supported
describe command('echo | openssl s_client -connect localhost:443 -tls1_2 2>&1') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^CONNECTED/ }
end

# Check for headers in HTTPS response
describe http('https://localhost', ssl_verify: false) do
  its('status') { should eq 200 }
  its('headers.Content-Type') { should match /text\/html/ }
  its('headers.X-Frame-Options') { should eq 'SAMEORIGIN' }
  its('headers.X-Content-Type-Options') { should eq 'nosniff' }
  its('headers.X-XSS-Protection') { should eq '1; mode=block' }
end
