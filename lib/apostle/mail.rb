require 'net/http'
require 'base64'
require 'json'

module Apostle

  class Mail

    attr_accessor :data,
      :email,
      :from,
      :headers,
      :layout_id,
      :name,
      :reply_to,
      :template_id,
      :_exception

    def initialize(template_id, options = {})
      @template_id = template_id
      @data = {}

      options.each do |k, v|
        self.send("#{k}=", v)
      end
    end

    # Provide a getter and setters for headers
    def header(name, value = nil)
      if value
        (@headers ||= {})[name] = value
      else
        (@headers || {})[name]
      end
    end

    # Allow convenience setters for the data payload
    # E.G. mail.potato= "Something" will set @data['potato']
    def method_missing(method, *args)
      return unless method.match /.*=/
      @data[method.to_s.gsub(/=$/, '')] = args.first
    end

    def deliver
      begin
        deliver!
        true
      rescue DeliveryError => e
        false
      end
    end

    # Shortcut method to deliver a single message
    def deliver!
      return true unless Apostle.deliver

      unless template_id && template_id != ""
        raise DeliveryError,
          "No email template_id provided"
      end

      queue = Apostle::Queue.new
      queue.add self
      queue.deliver!

      # Return true or false depending on successful delivery
      if queue.results[:valid].include?(self)
        return true
      else
        raise _exception
      end
    end

    def to_h
      {
        "#{self.email.to_s}" => {
          "data" => @data,
          "from" => from.to_s,
          "headers" => headers,
          "layout_id" => layout_id.to_s,
          "name" => name.to_s,
          "reply_to" => reply_to.to_s,
          "attachments" => encoded_attachments,
          "template_id" => template_id.to_s
        }.delete_if { |k, v| !v || v == '' }
      }
    end

    def to_json
      JSON.generate(to_h)
    end

    def attachments
      @_attachments ||= {}
    end

    private

    def encoded_attachments
      return nil unless @_attachments
      attachments.inject({}) do |h, (name, content)|
        h[name] = Base64.encode64(content)
        h
      end
    end


  end
end
