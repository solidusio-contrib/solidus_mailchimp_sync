# # frozen_string_literal: true

# require 'factory_bot'
# require 'spree/testing_support/factory_bot'

# Spree::TestingSupport::FactoryBot.add_paths_and_load!

# RSpec.configure do |config|
#   config.include FactoryBot::Syntax::Methods
# end


# require 'ffaker'
require 'factory_bot'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
