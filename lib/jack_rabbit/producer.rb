require 'jack_rabbit/client'

module JackRabbit
  class Producer
    include Client

    def initialize(logger = nil)
      @logger = logger
    end

    def connect(uri, options = {})
      @connection = open_connection(uri, options)
      @channel = open_channel(@connection, options)
    end

    def publish(exchange, type, key, message, headers = {})
      begin
        @channel
          .create_exchange(exchange, { type: type })
          .publish(message, headers.merge({ routing_key: key }))
      rescue Java::ComRabbitmqClient::AlreadyClosedException
        sleep(1)
        retry
      end
    end

    def disconnect
      @channel.close
      @connection.close
    end
  end
end
