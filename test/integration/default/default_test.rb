# frozen_string_literal: true

# InSpec integration tests for nginx cookbook

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
end

describe file('/etc/nginx/nginx.conf') do
  it { should exist }
  it { should be_file }
  its('mode') { should cmp '0644' }
end

describe directory('/etc/nginx') do
  it { should exist }
  it { should be_directory }
end

describe directory('/var/log/nginx') do
  it { should exist }
  it { should be_directory }
end

describe command('nginx -t') do
  its('exit_status') { should eq 0 }
  its('stderr') { should match(/syntax is ok/) }
  its('stderr') { should match(/test is successful/) }
end

describe http('http://localhost/', enable_remote_worker: true) do
  its('status') { should be_in [200, 301, 302, 403] }
end

# Security checks
describe file('/etc/nginx/nginx.conf') do
  its('content') { should_not match(/server_tokens\s+on/) }
end

# Check that user exists
describe user('nginx') do
  it { should exist }
end

describe group('nginx') do
  it { should exist }
end
