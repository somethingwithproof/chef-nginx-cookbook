# frozen_string_literal: true

source 'https://rubygems.org'

gem 'berkshelf', '>= 8.0'
gem 'chef', '>= 18.0'

group :development do
  gem 'chef-cli'
  gem 'chefspec'
  gem 'cookstyle'
  gem 'kitchen-dokken'
  gem 'kitchen-inspec'
  gem 'ruby-shadow' # For user resources
  gem 'test-kitchen'
end

group :test do
  gem 'concurrent-ruby'
  gem 'github-markup'
  gem 'inspec'
  gem 'inspec-bin'
  gem 'kitchen-vagrant'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'simplecov'
  gem 'simplecov-console'
end

group :docs do
  gem 'redcarpet'
  gem 'yard'
end
