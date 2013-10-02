require_relative 'spec_helper'

Penpal.domain_key = "abc123"

describe Penpal::Queue do
  it "sends the auth header" do
    stub = stub_request(:any, Penpal.delivery_host.to_s).with(
      headers: { "Authorization" => "Bearer abc123" }
    )
    queue = Penpal::Queue.new
    queue.send :deliver_payload, {}
    assert_requested(stub)
  end

  it "sends grouped requests" do
    queue = Penpal::Queue.new
    mail1 = Penpal::Mail.new "slug1", email: "recipient1"
    mail2 = Penpal::Mail.new "slug2", email: "recipient2"

    queue << mail1
    queue << mail2

    queue.emails.must_equal([mail1, mail2])

    payload, results = queue.send :process_emails
    results.must_equal({valid: [mail1, mail2], invalid: []})
    payload.must_equal({
      recipients: {
        "recipient1" => {"template_id" => "slug1", "data" => {} },
        "recipient2" => {"template_id" => "slug2", "data" => {} }
      }
    })
  end

  it "validates emails" do
    queue = Penpal::Queue.new
    mail1 = Penpal::Mail.new nil, email: "recipient1@example.com"
    mail2 = Penpal::Mail.new "slug2"

    queue << mail1
    queue << mail2

    queue.emails.must_equal([mail1, mail2])

    payload, results = queue.send :process_emails
    results.must_equal({invalid: [mail1, mail2], valid: []})

    mail1._exception.message.must_equal("No email template_id provided")
    mail2._exception.message.must_equal("No recipient provided")
    payload[:recipients].must_equal({})
  end

  describe "#deliver" do
    it "returns false if no delivery occurs" do
      queue = Penpal::Queue.new
      queue.deliver.must_equal(false)
    end
  end
end
