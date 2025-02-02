# frozen_string_literal: true

module SolidusMailchimpSync
  class Configuration
    attr_accessor :api_key,
                  :store_id,
                  :enabled,
                  :auto_sync_enabled,
                  :data_center

    def initialize
      @enabled = true
    end

    def self.data_center
      @data_center ||=
        if api_key.present?
          dc = api_key.split('-').last

          if dc.empty? || dc == api_key
            raise ArgumentError, "Mailchimp API key is expected to end in a hyphen and data center code, but was not found in `#{api_key}`, do not know how to proceed"
          end

          dc
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
