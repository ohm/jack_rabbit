require 'jack_rabbit/client'

module JackRabbit
  class Consumer
    include Client

    def initialize(logger = nil)
      @logger = logger
    end

    def connect(uris, options = {})
      @connections = uris.map { |uri| open_connection(uri, options) }
    end

    def subscribe(exchange, key, queue, options = {}, &block)
      @connections.each do |connection|
        channel = open_channel(connection, options)
        declare_subscription(channel, exchange, key, queue, options, &block)
      end
    end

    def disconnect
      @connections.each { |connection| connection.close }
    end

    private

    def declare_subscription(channel, exchange, key, queue, options, &block)
      channel
        .subscribe(exchange, key, queue, options, &block)
        .set_logger(@logger)
    end
  end
end

