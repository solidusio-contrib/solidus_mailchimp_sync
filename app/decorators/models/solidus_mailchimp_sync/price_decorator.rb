# frozen_string_literal: true

module SolidusMailchimpSync
  module PriceDecorator
    def self.prepended(base)
      base.after_commit :mailchimp_sync
    end

    private

    def mailchimp_sync
      if self.variant
        ::SolidusMailchimpSync::VariantSynchronizer.new(self.variant).auto_sync(force: true)
      end
    end

    ::Spree::Price.prepend(self)
  end
end
