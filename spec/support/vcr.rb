# frozen_string_literal: true

require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # Filter out basic auth
  config.filter_sensitive_data('<OMITTED AUTH HEADER>') do
    Base64.strict_encode64(
      "#{SolidusMailchimpSync::Mailchimp::AUTH_USER}:#{SolidusMailchimpSync::Config.api_key}"
    )
  end

  # Filter store_id and api key, and set them to defaults so code won't complain about missing
  # arguments.
  SolidusMailchimpSync::Config.store_id ||= 'dummy-store-id'
  SolidusMailchimpSync::Config.api_key ||= 'dummy-api-key-us1'
  config.filter_sensitive_data('dummy-store-id') { SolidusMailchimpSync::Config.store_id }
  config.filter_sensitive_data('dummy-api-key') { SolidusMailchimpSync::Config.api_key }
  config.filter_sensitive_data('us1') { SolidusMailchimpSync::Config.data_center }
end
