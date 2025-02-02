# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SolidusMailchimpSync::OrderSynchronizer', vcr: true, record: :new_episodes do
  let(:user) do
    create(
      :user,
      email: 'test-order-synchronizer@friendsoftheweb.org'
    )
  end
  let(:syncer) do
    SolidusMailchimpSync::OrderSynchronizer.new(order).tap do
      next unless order.user

      SolidusMailchimpSync::UserSynchronizer.new(order.user).sync
    end
  end

  before do
    # sync all variants so we can sync order
    order.variants.each do |variant|
      SolidusMailchimpSync::VariantSynchronizer.new(variant).sync
    end
  end

  after do
    delete_if_present("/carts/#{order.id}")
    delete_if_present("/orders/#{order.id}")
    delete_if_present("/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(order.user)}") if order.user
  end

  describe "not completed order" do
    let(:order) do
      create(
        :order_with_line_items,
        line_items_count: 2,
        user: user
      )
    end

    before do
      delete_if_present("/carts/#{order.id}")
    end

    it "syncs as cart" do
      response = syncer.sync
      expect_order_equals_mailchimp_response(
        order: order,
        response: response
      )

      response = SolidusMailchimpSync::Mailchimp.ecommerce_request(
        :get,
        "/carts/#{order.id}"
      )
      expect(response["status"]).to be_nil
      expect(response["checkout_url"])
        .to eq(
          spree.cart_url(
            host: Rails.application.routes.default_url_options[:host]
          )
        )
    end

    describe "empty order" do
      let(:order) do
        create(
          :order,
          user: user
        ).tap do |o|
          expect(o.line_items).to be_empty
        end
      end

      it "does not sync without error" do
        response = syncer.sync
      end
    end

    describe "existing order" do
      let(:new_variant) do
        create(:variant).tap do |v|
          SolidusMailchimpSync::VariantSynchronizer.new(v).sync
        end
      end

      before do
        syncer.sync
        # Make sure it's really there, seesm to fail sometimes, perhaps because of
        # lag on mailchimp revealing the thing it just added, doh.
        SolidusMailchimpSync::Mailchimp.ecommerce_request(
          :get,
          "/carts/#{order.id}"
        )
      end

      it "updates" do
        order.contents.remove_line_item(order.line_items.first)
        order.contents.add(new_variant)

        response = syncer.sync
        expect_order_equals_mailchimp_response(
          order: order,
          response: response
        )
      end

      describe "that turns into a completed order" do
        let(:order) { create(:order_ready_to_complete, user: user) }

        before do
          delete_if_present("/orders/#{order.id}")
          syncer.sync
          # make sure it's there as a cart
          SolidusMailchimpSync::Mailchimp.ecommerce_request(
            :get,
            "/carts/#{order.id}"
          )
        end

        it "deletes mailchimp cart and creates mailchimp order" do
          order.complete!
          response = syncer.sync
          expect(response["id"]).to eq(order.id.to_s)

          # Make sure order is there as an order
          SolidusMailchimpSync::Mailchimp.ecommerce_request(
            :get,
            "/orders/#{order.id}"
          )
          # and NOT as a cart
          error = SolidusMailchimpSync::Mailchimp.ecommerce_request(
            :get,
            "/carts/#{order.id}", return_errors: true
          )
          expect(error.status).to eq(404)
        end
      end

      describe "that becomes empty" do
        before do
          syncer.sync
          SolidusMailchimpSync::Mailchimp.ecommerce_request(
            :get,
            "/carts/#{order.id}"
          )
          order.line_items.destroy_all
          expect(order.line_items).to be_empty
        end

        it "deletes on sync" do
          syncer.sync
          # no longer present on mailchimp
          error = SolidusMailchimpSync::Mailchimp.ecommerce_request(
            :get,
            "/carts/#{order.id}",
            return_errors: true
          )
          expect(error.status).to eq(404)
        end
      end
    end
  end

  describe "completed order" do
    let(:shipment_cost) { 15.0.to_d }
    let(:completed_at) { Time.new(2016, 5, 5, 10, 10, 10, "+05:00") }
    let(:order) do
      create(
        :completed_order_with_totals,
        user: user,
        shipment_cost: shipment_cost
      ).tap do |o|
        o.update(completed_at: completed_at)
      end
    end

    before do
      delete_if_present("/orders/#{order.id}")
    end

    it "syncs as order" do
      response = syncer.sync
      expect_order_equals_mailchimp_response(
        order: order,
        response: response
      )

      response = SolidusMailchimpSync::Mailchimp.ecommerce_request(
        :get,
        "/orders/#{order.id}"
      )
      expect(response["status"]).to be_nil
      expect(response["shipping_total"]).to eq(shipment_cost)
      expect(Time.iso8601(response["processed_at_foreign"]))
        .to eq(order.completed_at.change(usec: 0))
    end

    describe "existing order" do
      let(:new_variant) do
        create(:variant).tap do |v|
          SolidusMailchimpSync::VariantSynchronizer.new(v).sync
        end
      end

      before do
        response = syncer.sync
        # just make sure it was really created
        SolidusMailchimpSync::Mailchimp.ecommerce_request(
          :get,
          "/orders/#{order.id}"
        )
      end

      it "updates" do
        order.contents.remove_line_item(order.line_items.first)
        order.contents.add(new_variant)

        response = syncer.sync
        expect_order_equals_mailchimp_response(
          order: order,
          response: response
        )
      end
    end
  end

  describe "order without user" do
    let(:order) { create(:order_with_line_items, user: nil) }

    it "can't sync" do
      response = syncer.sync
      expect(response).to be_nil
    end
  end

  # Email address chanages may make this happen.
  describe "order where user hasn't been synced yet" do
    let(:order) { create(:order_with_line_items, user: user) }
    let!(:syncer) { SolidusMailchimpSync::OrderSynchronizer.new(order) }

    before do
      delete_if_present("/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(order.user)}")
      # ensure user really hasn't synced as pre-condition
      response =
        SolidusMailchimpSync::Mailchimp.ecommerce_request(
          :get,
          "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(order.user)}",
          return_errors: true
        )

      expect(response).to be_kind_of(SolidusMailchimpSync::Error)
      expect(response.status).to eq(404)
    end

    it "syncs and creates user" do
      SolidusMailchimpSync::UserSynchronizer.new(order.user).sync
      response = syncer.sync
      SolidusMailchimpSync::Mailchimp.ecommerce_request(
        :get,
        "/carts/#{order.id}"
      )
      SolidusMailchimpSync::Mailchimp.ecommerce_request(
        :get,
        "/customers/#{SolidusMailchimpSync::UserSynchronizer.customer_id(order.user)}"
      )
    end
  end

  def expect_order_equals_mailchimp_response(order:, response:)
    expect(response['id']).to eq(order.id.to_s)
    expect(response['customer']['id'])
      .to eq(SolidusMailchimpSync::UserSynchronizer.customer_id(order.user))
    expect(response['order_total']).to eq(order.total)
    expect(response['tax_total']).to eq(order.tax_total)

    if order.completed_at.present?
      expect(Time.iso8601(response['processed_at_foreign']))
        .to eq(order.completed_at.change(usec: 0))
    end

    order.line_items.each do |line_item|
      response_line = response['lines'].find do |h|
        h['id'] == line_item.id.to_s
      end
      expect(response_line).to be_present

      expect(response_line['product_variant_id'])
        .to eq(line_item.variant.id.to_s)
      expect(response_line['product_id'])
        .to eq(line_item.product.id.to_s)
      expect(response_line['quantity']).to eq(line_item.quantity)
      expect(response_line['price']).to eq(line_item.price)
    end
  end
end
