require "penpal/version"
require 'penpal/mail'
require 'penpal/queue'
require 'uri'

module Penpal
  # TODO: Hardcode default delivery host
  @@delivery_host = URI(ENV['PENPAL_DELIVERY_HOST'] || 'http://penpal-deliver.herokuapp.com')
  @@domain_key = ENV['PENPAL_DOMAIN_KEY']
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
