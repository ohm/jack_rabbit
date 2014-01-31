require 'jack_rabbit/backoff'
require 'jack_rabbit/client'

module JackRabbit
  class Producer
    include Backoff
    include Client
    include Logging

    def initialize(logger = nil)
      @logger = logger
    end

    def connect(uri, options = {})
      @connection = open_connection(uri, options)
      @channel = open_channel(@connection, options)
    end

    def publish(exchange, type, key, message, headers = {})
      with_backoff(Java::ComRabbitmqClient::AlreadyClosedException) do
        debug('publishing to %s:%s with %s...' % [ type, exchange, key ])
        @channel
          .create_exchange(exchange, { exchange: { type: type } })
          .publish(message, headers.merge(routing_key: key))
      end
    end

    def disconnect
      @channel.close
      @connection.close
    end
  end
end
