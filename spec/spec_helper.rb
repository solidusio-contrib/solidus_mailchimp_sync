ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError
  `bin/rails db:migrate`
end

# Requires factories defined in lib/solidus_mailchimp_sync/factories.rb
require 'solidus_mailchimp_sync/factories'

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.fail_fast = ENV['FAIL_FAST'] || false
  config.order = 'random'
end

Rails.application.routes.default_url_options[:host] = 'www.example.com'
SolidusMailchimpSync.auto_sync_enabled = false
