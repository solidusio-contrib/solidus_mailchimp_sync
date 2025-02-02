# frozen_string_literal: true

module SolidusMailchimpSync
  module OrderDecorator
    def self.prepended(base)
      base.after_commit :mailchimp_sync
    end

    private

    def mailchimp_sync
      ::SolidusMailchimpSync::OrderSynchronizer.new(self).auto_sync
    end

    ::Spree::Order.prepend(self)
  end
end
