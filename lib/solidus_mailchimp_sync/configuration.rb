# frozen_string_literal: true

module SolidusMailchimpSync
  class Configuration < Spree::Preferences::Configuration
    preference :api_key, :string
    preference :store_id, :string
    preference :enabled, :boolean, default: true
    preference :auto_sync_enabled, :boolean, default: false

    def data_center
      if api_key.present?
        data_center = api_key.split('-').last

        if data_center.empty? || data_center == api_key
          raise ArgumentError, "Mailchimp API key is expected to end in a hyphen and data center code, but was not found in `#{api_key}`, do not know how to proceed"
        end

        data_center
      end
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
