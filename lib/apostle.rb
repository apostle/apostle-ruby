require 'apostle/version'
require 'apostle/mail'
require 'apostle/queue'
require 'uri'

module Apostle
  @@delivery_host = URI(ENV['APOSTLE_DELIVERY_HOST'] || 'http://deliver.apostle.io')
  @@domain_key = ENV['APOSTLE_DOMAIN_KEY']
  @@deliver = true

  def self.delivery_host=(host)
    @@delivery_host = host
  end

  # Lazily create a delivery_host URI
  def self.delivery_host
    if @@delivery_host.is_a?(URI)
      @@delivery_host
    else
      URI(@@delivery_host)
    end
  end

  def self.domain_key=(key)
    @@domain_key = key
  end

  def self.domain_key
    @@domain_key
  end

  def self.deliver=(bool)
    @@deliver = !!bool
  end

  def self.deliver
    @@deliver
  end

  class << self
    def configure
      yield self
    end
  end

  Error = Class.new(StandardError)
  DeliveryError = Class.new(Error)
  Unauthorized = Class.new(DeliveryError)
  Forbidden = Class.new(DeliveryError)
  UnprocessableEntity = Class.new(DeliveryError)
  ServerError = Class.new(DeliveryError)
end
