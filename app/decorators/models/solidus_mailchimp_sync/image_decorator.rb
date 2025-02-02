# frozen_string_literal: true

module SolidusMailchimpSync
  module ImageDecorator
    def self.prepended(base)
      base.after_commit :mailchimp_sync
    end

    private

    def mailchimp_sync
      if self.viewable.is_a?(::Spree::Variant)
        if self.viewable.is_master?
          # Need to sync all variants.
          ::SolidusMailchimpSync::ProductSynchronizer.new(self.viewable.product).auto_sync(force: true)
        else
          # image just on this variant, just need to sync this one.
          ::SolidusMailchimpSync::VariantSynchronizer.new(self.variant).auto_sync(force: true)
        end
      end
    end

    ::Spree::Image.prepend(self)
  end
end
