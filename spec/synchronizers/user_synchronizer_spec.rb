# frozen_string_literal: true

require 'spec_helper'

describe 'SolidusMailchimpSync::UserSynchronizer', vcr: true do
  let(:syncer) { SolidusMailchimpSync::UserSynchronizer.new(user) }
  let(:user) do
    create(
      :user,
      email: "test-user-synchronizer@friendsoftheweb.org"
    )
  end

  before do
    delete_if_present "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(user)}"
  end

  after do
    delete_if_present "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(user)}"
  end

  describe "new user" do
    it "syncs" do
      response = syncer.sync

      expect(response["id"]).to eq(SolidusMailchimpSync::UserSynchronizer.customer_id(user))
      expect(response["email_address"]).to eq(user.email)
    end
  end

  describe "already exists on mailchimp" do
    before do
      syncer.sync
      # Ensure it's present
      response = SolidusMailchimpSync::Mailchimp.ecommerce_request(:get, "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(user)}")
    end

    it "syncs" do
      response = syncer.sync
      expect(response["id"]).to eq(SolidusMailchimpSync::UserSynchronizer.customer_id(user))
      expect(response["email_address"]).to eq(user.email)
    end

    describe "email address changes" do
      let(:previous_id) { syncer.mailchimp_id }

      before do
        user.email = 'new-test-user-synchronizer@friendsoftheweb.com'
        user.save!
      end

      it 'syncs' do
        response = syncer.sync
        expect(response['id'])
          .to eq(SolidusMailchimpSync::UserSynchronizer.customer_id(user))
        expect(response['email_address']).to eq(user.email)

        # It will have a new ID, it's a different mailchimp record, and we
        # don't currently have anything to delete the old one.
        expect(response['id']).not_to eq(previous_id)
      end
    end
  end
end
