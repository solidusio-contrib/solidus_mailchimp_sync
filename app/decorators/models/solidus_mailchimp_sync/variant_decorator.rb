# frozen_string_literal: true

module SolidusMailchimpSync
  module VariantDecorator
    def self.prepended(base)
      base.after_commit :mailchimp_sync
    end

    private

    def mailchimp_sync
      ::SolidusMailchimpSync::VariantSynchronizer.new(self).auto_sync
    end

    ::Spree::Variant.prepend(self)
  end
end
