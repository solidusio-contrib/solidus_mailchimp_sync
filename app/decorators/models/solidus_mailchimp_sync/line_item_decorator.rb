# frozen_string_literal: true

module SolidusMailchimpSync
  module LineItemDecorator
    def self.prepended(base)
      base.after_commit :mailchimp_sync
    end

    def mailchimp_sync
      # If a LineItem changes, tell the order to Sync for sure.
      ::SolidusMailchimpSync::OrderSynchronizer.new(order).auto_sync(force: true)
    end

    ::Spree::LineItem.prepend(self)
  end
end
