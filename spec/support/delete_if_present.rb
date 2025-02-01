# frozen_string_literal: true

def delete_if_present(mailchimp_api_url)
  response = SolidusMailchimpSync::Mailchimp.ecommerce_request(:delete, mailchimp_api_url, return_errors: true)

  if response.is_a?(SolidusMailchimpSync::Error) && response.status != 404
    raise response
  end

  response
end
