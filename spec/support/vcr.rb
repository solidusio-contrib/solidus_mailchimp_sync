# frozen_string_literal: true

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
  config.filter_sensitive_data('<OMITTED AUTH HEADER>') do
    Base64.strict_encode64(
      "#{SolidusMailchimpSync::Mailchimp::AUTH_USER}:#{SolidusMailchimpSync::Config.api_key}"
    )
  end

  # Filter store_id and api key, and set them to defaults so code won't complain about missing
  # arguments.
  SolidusMailchimpSync::Config.store_id ||= 'eb4d0f9784'
  SolidusMailchimpSync::Config.api_key ||= '78749fe6f9af9033b5171dd34469299a-us7'
  config.filter_sensitive_data('dummy-store-id') { SolidusMailchimpSync::Config.store_id }
  config.filter_sensitive_data('dummy-api-key') { SolidusMailchimpSync::Config.api_key }
  config.filter_sensitive_data('us1') { SolidusMailchimpSync::Config.data_center }
end
