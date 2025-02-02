# frozen_string_literal: true

module SolidusMailchimpSync
  module UserDecorator
    def self.prepended(base)
      base.after_commit :mailchimp_sync
    end

    private

    def mailchimp_sync
      ::SolidusMailchimpSync::UserSynchronizer.new(self).auto_sync
    end

    ::Spree.user_class.prepend(self)
  end
end
