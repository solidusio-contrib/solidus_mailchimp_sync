[WIP] SolidusMailchimpSync


> [!CAUTION]
> This extension is not production ready, work is in progress.

====================<br>
[![CircleCI](https://circleci.com/gh/solidusio-contrib/solidus_mailchimp_sync.svg?style=shield)](https://circleci.com/gh/solidusio-contrib/solidus_mailchimp_sync)

Synchronizes Solidus data with [Mailchimp E-Commerce API](http://developer.mailchimp.com/documentation/mailchimp/guides/getting-started-with-ecommerce/). (Mailchimp API 3.0)

This plugin does not do every kind of integration with Mailchimp that might be possible, it just focuses
on synchronizing data from Solidus to Mailchimp, by adding ActiveRecord lifecycle
hooks to Solidus models.

* Solidus `User` to Mailchimp `Customer`. (All customers currently added as status `transactional` in Mailchimp)
* Solidus `Product`, `Variant` (and images) to Mailchimp `Product` and `Variant`.
* Solidus `Order` (and their `LineItem`s), to Mailchimp `Cart` and `Order` (and their `Line`s).

Not all possible attributes that can be sync'd may yet be synced. It does
not yet sync Order payment/cancel/return/shipment state. It does not yet sync Customer
`orders_count`/`total_spent`. Some Mailchimp E-Commerce features may require these, others
are still usable.

Right now this plugin will connect everything in Solidus to a single Mailchimp `Store`, it does
not support multiple Mailchimp Stores.

We do not (yet?) support Mailchimp E-Commerce Link Tracking.

Actual sync'ing is done in background jobs using ActiveJob, configure your
ActiveJob adapter. All jobs are idempotent.

Installation
------------

Add solidus_mailchimp_sync to your Gemfile:

```ruby
gem 'solidus_mailchimp_sync'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g solidus_mailchimp_sync:install
```

Your app will need to set `default_url_options[:host]` so urls can be
sent to mailchimp in background. :

     config.action_mailer.default_url_options = { host: 'mystore.example.org' }

Review the generated `./config/initializers/solidus_mailchimp_sync.rb` for required
and optional config, including mailchimp api keys.

You will need to have a Mailchimp List already created. You will need to create
a Mailchimp `Store` object belonging to that list, that we'll use for synchronization.
Not sure if that can be created through anything but API. You can create one by:

    bundle exec rake solidus_mailchimp_sync:create_mailchimp_store LIST_ID=list-id-from-mailchimp

Then add the storeID for created store to your configuration.

Before going live, you will probably want to bulk-add all your existing data --
if existing products aren't added, orders won't be able to be synced. This
could take a while:

    RAILS_ENV=production rake solidus_mailchimp_sync:bulk_sync

Lower-level tools
------------------

This gem only synchronizes data with the Mailchimp E-Commerce API, but you
may find it's methods useful for writing your own code to interact with
the Mailchimp API.  `SolidusMailchimpSync::Mailchimp.request` can be
used to make API requests using the configured API key, and raising
`SolidusMailchimp::Error` objects on failures. And `SolidusMailchimpSync::Util.subscriber_hash`
can create the ID/key/hash object for a Mailchimp [Member](http://developer.mailchimp.com/documentation/mailchimp/reference/lists/members/) object.

This gem doesn't have any built-in automatic opt-in checkbox, but here is a call
that could be used to subscribe a user to a Mailchimp list:

~~~ruby
 SolidusMailchimpSync::Mailchimp.request(
      :put,
      "/lists/#{ENV['MAILCHIMP_LIST_ID']}/members/#{SolidusMailchimpSync::Util.subscriber_hash(user.email)}",
      body: {
        status: "pending"
        email_address: user.email
      })
~~~

Known issues/To do
------------------

* If a user changes their email addresses, their old orders may be no longer associated with
  them in mailchimp, they will wind up with two mailchimp customer records. (Mailchimp
  docs suggest you can change an existing Customer's id itself, but it didn't seem to work.
  can't change an existing Customer's email address)

* Mailchimp API does not let us update products. This is problematic if for instance
  available_on changes, or other metadata like image/description/title etc. We
  haven't found a good workaround, trying to delete and recreate product in
  Mailchimp is also problematic. We do try to avoid sync'ing product until
  it's `available`, with this logic being customizable.

* Debounce: This may send a LOT of updates to mailchimp, when you're editing something.
  In checkout process there are sometimes multiple syncs for order, not sure why.
  Have an idea for an implementation debounce feature that could debounce/coalesce mailchimp
  syncs in the general case.

Maintenance Expectations
------------------------

We've develoepd this for our own clients needs. We are sharing it with the intention
of sharing/collaborating with other developers, so they don't have to re-invent
the wheel.

We think this is solid and reliable code, but our future ability to attend to
any maintenance or development will depend on our time and clients needs. We
will do our best to respond to PR'.

Testing
-------

First bundle your dependencies, then run `rake`. `rake` will default to building the dummy app if it does not exist, then it will run specs, and [Rubocop](https://github.com/bbatsov/rubocop) static code analysis. The dummy app can be regenerated by using `rake test_app`.

```shell
bundle
bundle exec rake
```

Some tests use VCR to record live transactions with mailchimp. To run these tests while
recording new cassettes, you will need to set ENV `MAILCHIMP_API_KEY` and `MAILCHIMP_STORE_ID`.
**Note** these should be a test/dummy mailchimp account, as data will be edited by tests.

When testing your applications integration with this extension you may use it's factories.
(No factories at present)
Simply add this require statement to your spec_helper:

```ruby
require 'solidus_mailchimp_sync/factories'
```

Copyright (c) 2016 Friends of the Web LLC, released under the New BSD License
