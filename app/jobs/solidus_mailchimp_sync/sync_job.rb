# frozen_string_literal: true

module SolidusMailchimpSync
  class SyncJob < ApplicationJob
    class_attribute :use_queue_name
    use_queue_name = :default

    queue_as do
      self.use_queue_name
    end

    def perform(synchronizer_class_name, model)
      synchronizer = synchronizer_class_name.constantize.new(model)
      synchronizer.sync
    end
  end
end
