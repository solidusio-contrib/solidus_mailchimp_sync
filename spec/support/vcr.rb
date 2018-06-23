require 'vcr'
require 'webmock'

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
  config.configure_rspec_metadata!

  config.default_cassette_options = {
    record: ENV['VCR_RECORD'].present? ? ENV['VCR_RECORD'].to_sym : :once
  }

  # Filter out basic auth
  config.filter_sensitive_data('<OMITTED AUTH HEADER>') { Base64.strict_encode64("#{SolidusMailchimpSync::Mailchimp::AUTH_USER}:#{SolidusMailchimpSync.api_key}") }

  # Filter store_id and api key, and set them to defaults so code won't complain about missing
  # arguments.
  SolidusMailchimpSync.store_id ||= "dummy-store-id"
  SolidusMailchimpSync.api_key ||= 'dummy-api-key-us1'
  config.filter_sensitive_data('dummy-store-id') { SolidusMailchimpSync.store_id }
  config.filter_sensitive_data("dummy-api-key") { SolidusMailchimpSync.api_key }
  config.filter_sensitive_data("us1") { SolidusMailchimpSync.data_center }
end
