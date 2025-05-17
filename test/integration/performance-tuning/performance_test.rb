# InSpec test for recipe nginx::default with performance tuning

describe port(80) do
  it { should be_listening }
  its('protocols') { should include 'tcp' }
  its('processes') { should include 'nginx' }
end

describe file('/etc/nginx/nginx.conf') do
  it { should exist }
  it { should be_file }
  its('content') { should match /worker_processes\s+auto;/ }
  its('content') { should match /worker_connections\s+4096;/ }
  its('content') { should match /worker_rlimit_nofile\s+8192;/ }
  its('content') { should match /multi_accept\s+on;/ }
  its('content') { should match /keepalive_timeout\s+30;/ }
  its('content') { should match /keepalive_requests\s+200;/ }
  its('content') { should match /sendfile\s+on;/ }
  its('content') { should match /tcp_nopush\s+on;/ }
  its('content') { should match /tcp_nodelay\s+on;/ }
  its('content') { should match /open_file_cache\s+max=10000\s+inactive=30s;/ }
  its('content') { should match /open_file_cache_valid\s+60s;/ }
  its('content') { should match /open_file_cache_min_uses\s+2;/ }
  its('content') { should match /open_file_cache_errors\s+on;/ }
  its('content') { should match /gzip\s+on;/ }
  its('content') { should match /gzip_comp_level\s+4;/ }
end

# Check system limits for worker processes
describe command('ulimit -n') do
  its('stdout.to_i') { should be >= 1024 }
end

# Check response times for basic requests
describe command('curl -s -o /dev/null -w "%{time_total}" http://localhost/') do
  its('stdout.to_f') { should be < 1.0 }
end
