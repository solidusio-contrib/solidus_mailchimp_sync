# frozen_string_literal: true

Spree.user_class.class_eval do
  after_commit :mailchimp_sync

  private

  def mailchimp_sync
    SolidusMailchimpSync::UserSynchronizer.new(self).auto_sync
  end
end
