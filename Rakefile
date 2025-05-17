require 'cookstyle'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'kitchen/rake_tasks'

namespace :style do
  desc 'Run Ruby style checks'
  RuboCop::RakeTask.new(:ruby) do |task|
    task.options << '--display-cop-names'
  end
end

desc 'Run all style checks'
task style: ['style:ruby']

desc 'Run ChefSpec examples'
RSpec::Core::RakeTask.new(:spec)

desc 'Run Test Kitchen integration tests'
namespace :integration do
  desc 'Run Test Kitchen tests using Docker'
  task :docker do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new(kitchen_yaml: '.kitchen.yml').instances.each do |instance|
      instance.test(:always)
    end
  end

  desc 'Run Test Kitchen tests using Vagrant'
  task :vagrant do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new(kitchen_yaml: '.kitchen.vagrant.yml').instances.each do |instance|
      instance.test(:always)
    end
  end

  desc 'Run Test Kitchen tests using Dokken'
  task :dokken do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new(kitchen_yaml: '.kitchen.dokken.yml').instances.each do |instance|
      instance.test(:always)
    end
  end
end

desc 'Run all tests on CI pipeline'
task ci: ['style', 'spec', 'integration:dokken']

desc 'Regenerate documentation from templates'
task :docs do
  puts 'Generating documentation...'
  # Add documentation generation logic here if needed
end

task default: ['style', 'spec']