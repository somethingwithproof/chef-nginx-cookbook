require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start! { add_filter 'nginx' }

RSpec.configure do |config|
  config.platform = 'ubuntu'
  config.version = '20.04'
  config.log_level = :error
  config.formatter = :documentation
  config.color = true
end
