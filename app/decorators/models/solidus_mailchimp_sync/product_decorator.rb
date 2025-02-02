# frozen_string_literal: true

module SolidusMailchimpSync
  module ProductDecorator
    def self.prepended(base)
      base.after_commit :mailchimp_sync
    end

    private

    def mailchimp_sync
      ::SolidusMailchimpSync::ProductSynchronizer.new(self).auto_sync
    end

    ::Spree::Product.prepend(self)
  end
end
