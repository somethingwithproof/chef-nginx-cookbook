# InSpec test for recipe nginx::default with multiple sites

describe port(80) do
  it { should be_listening }
  its('protocols') { should include 'tcp' }
  its('processes') { should include 'nginx' }
end

# Test for default site
describe http('http://localhost') do
  its('status') { should eq 200 }
  its('body') { should match /Welcome to nginx!/ }
end

# Test for site1.example.com (using Host header)
describe http('http://localhost', headers: {'Host' => 'site1.example.com'}) do
  its('status') { should eq 200 }
  its('body') { should match /site1.example.com/ }
end

# Test for site2.example.com (using Host header)
describe http('http://localhost', headers: {'Host' => 'site2.example.com'}) do
  its('status') { should eq 200 }
  its('body') { should match /site2.example.com/ }
end

# Test for configuration files
describe file('/etc/nginx/sites-available/site1.example.com.conf') do
  it { should exist }
  it { should be_file }
  its('content') { should match /server_name site1.example.com;/ }
end

describe file('/etc/nginx/sites-available/site2.example.com.conf') do
  it { should exist }
  it { should be_file }
  its('content') { should match /server_name site2.example.com;/ }
end

# Test symlinks for Debian based systems
if os.debian? || os.ubuntu?
  describe file('/etc/nginx/sites-enabled/site1.example.com.conf') do
    it { should be_symlink }
    it { should be_linked_to '/etc/nginx/sites-available/site1.example.com.conf' }
  end

  describe file('/etc/nginx/sites-enabled/site2.example.com.conf') do
    it { should be_symlink }
    it { should be_linked_to '/etc/nginx/sites-available/site2.example.com.conf' }
  end
end
