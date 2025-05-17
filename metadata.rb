name 'nginx'
maintainer 'Thomas Vincent'
maintainer_email 'thomasvincent@gmail.com'
license 'Apache-2.0'
description 'Installs and configures Nginx with comprehensive functionality'
version '1.1.0'
chef_version '>= 18.0', '< 19.0'
source_url 'https://github.com/thomasvincent/chef-nginx-cookbook'
issues_url 'https://github.com/thomasvincent/chef-nginx-cookbook/issues'

# Ubuntu LTS releases
supports 'ubuntu', '>= 18.04'
# Debian
supports 'debian', '>= 10.0'
# RHEL
supports 'redhat', '>= 7.0'
# Amazon Linux
supports 'amazon', '>= 2.0'
# Rocky Linux (RHEL-compatible)
supports 'rocky', '>= 8.0'
# AlmaLinux (RHEL-compatible)
supports 'alma', '>= 8.0'
# Oracle Enterprise Linux
supports 'oracle', '>= 7.0'
# SUSE Linux Enterprise Server
supports 'suse', '>= 12.0'
# FreeBSD
supports 'freebsd', '>= 13.0'
# Windows Server and Desktop
supports 'windows', '>= 10'
# macOS
supports 'mac_os_x', '>= 12.0'
# EPEL repository is now configured directly in the install resource
depends 'apt', '>= 8.0'
depends 'selinux', '>= 6.0'
