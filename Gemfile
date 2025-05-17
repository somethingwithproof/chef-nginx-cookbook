source 'https://rubygems.org'

group :development do
  gem 'cookstyle'
  gem 'rspec', '~> 3.12'
  gem 'chefspec', '~> 9.3'
  # Use policyfiles instead of Berkshelf
  gem 'chef-cli', '~> 5.6'
  gem 'kitchen-docker'
  gem 'kitchen-vagrant'
  gem 'kitchen-inspec'
  gem 'test-kitchen'
  gem 'winrm', '~> 2.3'
  gem 'winrm-fs', '~> 1.3'
  # For macOS local development
  gem 'rb-readline'
  # Platform-specific gems
  gem 'syslog', '~> 0.3.0', platforms: :ruby
  gem 'win32-service', platforms: [:mswin, :mingw]
  gem 'wmi-lite', platforms: [:mswin, :mingw]
end

group :ci do
  gem 'kitchen-dokken'
  gem 'github_changelog_generator'
  gem 'rake'
end

group :debug do
  gem 'pry'
  gem 'pry-byebug'
end
