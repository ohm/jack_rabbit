require 'jack_rabbit/connection'

module JackRabbit
  class Consumer
    def initialize(logger)
      @logger = logger
    end

    def connect(uris, options = {})
      @connections =
        uris.map do |uri|
          Connection.new(uri, options)
            .set_logger(@logger)
            .open
        end
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

    def open_channel(connection, options)
      connection
        .channel(options)
        .set_logger(@logger)
    end

    def declare_subscription(channel, exchange, key, queue, options, &block)
      channel
        .subscribe(exchange, key, queue, options, &block)
        .set_logger(@logger)
    end
  end
end
