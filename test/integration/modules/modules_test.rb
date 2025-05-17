# InSpec test for recipe nginx::default with module support

describe port(80) do
  it { should be_listening }
  its('protocols') { should include 'tcp' }
  its('processes') { should include 'nginx' }
end

# Test status module
describe file('/etc/nginx/conf.d/status.conf') do
  it { should exist }
  it { should be_file }
  its('content') { should match /location \/nginx_status/ }
  its('content') { should match /stub_status on;/ }
end

# Test access to nginx status
describe http('http://localhost/nginx_status', enable_remote_worker: true) do
  its('status') { should eq 403 }
  # Public access should be denied
end

describe http('http://127.0.0.1/nginx_status', enable_remote_worker: true) do
  its('status') { should eq 200 }
  its('body') { should match /Active connections:/ }
  its('body') { should match /server accepts handled requests/ }
  its('body') { should match /Reading: \d+ Writing: \d+ Waiting: \d+/ }
end

# Test headers_more module if available on the platform
# This is a conditional test as it may not be available on all platforms
describe file('/etc/nginx/modules-enabled/headers-more-filter.conf'), :if => os.debian? || os.ubuntu? do
  it { should exist }
  it { should be_file }
end

# On RHEL-based systems, the module file might be in a different location
describe file('/etc/nginx/conf.d/headers-more-filter.conf'), :if => os.redhat? || os.name == 'amazon' do
  it { should exist }
  it { should be_file }
end
