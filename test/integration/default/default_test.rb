# InSpec test for recipe nginx::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec/resources/

describe package('nginx') do
  it { should be_installed }
end

describe service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
  its('protocols') { should include 'tcp' }
  its('processes') { should include 'nginx' }
end

describe nginx do
  its('version') { should match /\d+\.\d+\.\d+/ }
end

describe http('http://localhost') do
  its('status') { should eq 200 }
  its('body') { should match /Welcome to nginx!/ }
end

describe file('/etc/nginx/nginx.conf') do
  it { should exist }
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should match /worker_processes/ }
end

describe file('/var/log/nginx') do
  it { should exist }
  it { should be_directory }
end

describe file('/var/log/nginx/access.log') do
  it { should exist }
  it { should be_file }
end

describe file('/var/log/nginx/error.log') do
  it { should exist }
  it { should be_file }
end
