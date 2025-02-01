# frozen_string_literal: true

Spree::Order.class_eval do
  after_commit :mailchimp_sync

  private

  def mailchimp_sync
    SolidusMailchimpSync::OrderSynchronizer.new(self).auto_sync
  end
end
