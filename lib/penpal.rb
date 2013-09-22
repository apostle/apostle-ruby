require "penpal/version"
require 'penpal/mail'
require 'penpal/queue'
require 'uri'

module Penpal
  # TODO: Hardcode default delivery host
  @@delivery_host = URI(ENV['PENPAL_DELIVERY_HOST'] || 'http://0.0.0.0:3001')
  @@app_key = ENV['PENPAL_APP_KEY']

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

  def self.app_key=(key)
    @@app_key = key
  end

  def self.app_key
    @@app_key
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
