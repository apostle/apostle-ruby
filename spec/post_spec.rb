require_relative 'spec_helper'
require 'penpal'

describe Penpal::Mail do
  before do
    Penpal.configure do |config|
     config.app_key = "abc"
    end
  end

  describe "#initialize" do
    it "assigns template and attributes" do
      mail = Penpal::Mail.new "template_slug",
        email: "email address",
        unknown_key: "val"

      mail.email.must_equal "email address"
      mail.template_id.must_equal "template_slug"
      mail.data.must_equal({ "unknown_key" => "val" })
    end
  end

  describe "#deliver!" do
    it "returns raises an exception without a template id" do
      mail = Penpal::Mail.new nil
      expect(mail.deliver!).to raise_error(Penpal::DeliveryError, "No template")
    end

    it "delegates to a queue" do
    end

    it "raises any error returned"
  end

  describe "to_json" do
    it "returns a json representaion of the hash"
  end

  describe "to_h" do
    it "returns a hash of attributes" do
      mail = Penpal::Mail.new "template_slug"
      mail.from = :f
      mail.email = 123
      mail.reply_to = "someone"
      mail.name = "name"
      mail.data = { "Hello" => "World" }
      mail.foo = 'Bar'
      mail.to_h.must_equal({"123" => {
        "template_id" => "template_slug",
        "from" => "f",
        "reply_to" => "someone",
        "name" => "name",
        "data" => { "Hello" => "World", "foo" => "Bar"}
      }})
    end
    it "removes nil entries" do
      mail = Penpal::Mail.new "slug"
      mail.email = "to"
      mail.to_h.must_equal({"to" => {
        "template_id" => "slug",
        "data" => {}
      }})
    end
  end
end
