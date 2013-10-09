require 'json'

module Apostle

  class Queue

    attr_accessor :emails, :results

    def initialize
      @emails = []
    end

    def <<(email)
      add(email)
    end

    def add(email)
      @emails << email
    end

    def size
      emails.size
    end

    def clear
      emails = []
      results = nil
    end

    def flush
      deliver && clear
    end

    def deliver
      deliver!
    rescue DeliveryError
      false
    end

    def deliver!
      return true unless Apostle.deliver

      # Validate the minimum requirement of a recipient and template
      unless Apostle.domain_key
        raise DeliveryError,
          "No Apostle Domain Key has been defined. Preferably this should be in your environment, as ENV['APOSTLE_DOMAIN_KEY']. If you need to configure this manually, you can call Apostle.configure.

      Apostle.configure do |config|
        config.domain_key = 'Your domain key'
      end"
      end

      raise DeliveryError, "Mail queue is empty" if emails.size == 0

      payload, @results = process_emails

      if @results[:invalid].size > 0
        raise DeliveryError,
          "Invalid emails: #{@results[:invalid].size}"
      end

      # Deliver the payload
      response = deliver_payload(payload)

      true
    end

    private

    def process_emails
      results = { valid: [], invalid: [] }

      payload = {recipients: {}}

      emails.each do |mail|
        # Validate each mail
        begin
          unless mail.email && mail.email != ""
            raise DeliveryError,
              "No recipient provided"
          end

          unless mail.template_id && mail.template_id != ""
            raise DeliveryError,
              "No email template_id provided"
          end

          payload[:recipients].merge!(mail.to_h)
          results[:valid] << mail
        rescue => e
          results[:invalid] << mail
          mail._exception = e
        end
      end

      [payload, results]
    end

    def deliver_payload(payload)
      delivery_api = Apostle.delivery_host

      req = Net::HTTP::Post.new(
        "/",
        'Content-Type' =>'application/json',
        "Authorization" => "Bearer #{Apostle.domain_key}")
      if delivery_api.user
        req.basic_auth delivery_api.user, delivery_api.password
      end
      req.body = JSON.generate(payload)
      response = Net::HTTP.
        new(delivery_api.host, delivery_api.port).
        start do |http|
          http.request(req)
        end

      # Successful request
      if [200, 201, 202].include?(response.code.to_i)
        return true
      end

      begin
        json = JSON.parse(response.body)
      rescue JSON::ParserError
        json = {}
      end

      if json["message"]
        message = json["message"]
      else
        response.body
      end

      raise case response.code.to_i
      when 401
        Apostle::Unauthorized
      when 403
        Apostle::Forbidden
      when 422
        Apostle::UnprocessableEntity
      when 500
        Apostle::ServerError
      else
        Apostle::DeliveryError
      end, message

      response
    end

  end
end
