# Policyfile.rb - Describes how you want Chef Infra Client to build your system.

name 'nginx'
default_source :supermarket
run_list 'nginx::default'

cookbook 'nginx', path: '.'
cookbook 'apt', '~> 8.0'
cookbook 'selinux', '~> 6.0'