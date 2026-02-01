# frozen_string_literal: true

name 'nginx'
maintainer 'Thomas Vincent'
maintainer_email 'thomasvincent@example.com'
license 'Apache-2.0'
description 'Installs and configures Nginx with comprehensive functionality'
version '1.0.0'
chef_version '>= 18.0'
source_url 'https://github.com/thomasvincent/chef-nginx-cookbook'
issues_url 'https://github.com/thomasvincent/chef-nginx-cookbook/issues'

# Supported platforms as of January 2026
# Linux - Docker/Dokken testable
supports 'ubuntu', '>= 22.04'
supports 'debian', '>= 12.0'
supports 'redhat', '>= 9.0'
supports 'amazon', '>= 2023.0'
supports 'rocky', '>= 9.0'
supports 'almalinux', '>= 9.0'

# BSD - Vagrant testable
supports 'freebsd', '>= 14.0'

# macOS - Vagrant or local testable
supports 'mac_os_x', '>= 13.0'
depends 'yum-epel', '>= 4.1'
depends 'apt', '>= 7.0'
depends 'selinux', '>= 6.0'
