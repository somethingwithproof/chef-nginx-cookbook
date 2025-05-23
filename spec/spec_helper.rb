# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'
require 'simplecov'

# Start SimpleCov for test coverage reporting
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_filter '/.kitchen/'
  add_filter '/test/'
  add_group 'Libraries', 'libraries'
  add_group 'Resources', 'resources'
  add_group 'Recipes', 'recipes'
  minimum_coverage 80
end

# Specify platform and version for ChefSpec
RSpec.configure do |config|
  # Use color in outputs
  config.color = true
  
  # Use detailed output formatter
  config.formatter = :documentation
  
  # Set log level to minimize output noise
  config.log_level = :error
  
  # Default platform for tests
  config.platform = 'ubuntu'
  config.version = '20.04'
  
  # Enable expectations syntax
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  
  # Configure mocks
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  
  # Shared context behavior
  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# Create a ChefSpec runner context
def chef_run(platform: 'ubuntu', version: '20.04', step_into: [], &block)
  runner = ChefSpec::SoloRunner.new(
    platform: platform,
    version: version,
    step_into: step_into
  )
  runner.instance_eval(&block) if block_given?
  runner.converge(described_recipe)
end

