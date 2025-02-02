# frozen_string_literal: true

require 'spree/core'
require 'solidus_mailchimp_sync'

module SolidusMailchimpSync
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace SolidusMailchimpSync

    engine_name 'solidus_mailchimp_sync'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    initializer 'solidus_mailchimp_sync.environment', before: :load_config_initializers do |_app|
      SolidusMailchimpSync::Config = SolidusMailchimpSync::Configuration.new
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
