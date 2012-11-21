require 'hot_bunnies'

module JackRabbit
  class Producer
    EXCHANGE_OPTIONS = { auto_delete: false, durable: true }

    def connect(uri, options = {})
      @channel = (@connection = open_connection(uri, options)).create_channel
    end

    def disconnect
      [ @channel, @connection ].each(&:close)
    end

    def publish(exchange_name, exchange_type, routing_key, message, headers = {})
      with_exchange(@channel, exchange_name, exchange_type) do |exchange|
        exchange.publish(message, headers.merge(routing_key: routing_key))
      end
    end

    private

    def open_connection(uri, options)
      connection =
        HotBunnies.connect(options.merge(
          host: uri.host,
          pass: uri.password,
          port: uri.port,
          user: uri.user,
          vhost: uri.path
        ))
      connection.add_shutdown_listener { |_reason| exit! }
      connection
    end

    def open_channel(connection)
      channel = connection.open_channel
      channel.add_shutdown_listener { |_reason| exit! }
      channel
    end

    def with_exchange(channel, exchange_name, exchange_type, &block)
      block.call(
        channel.exchange(exchange_name, EXCHANGE_OPTIONS.merge(
          type: exchange_type
        ))
      )
    end
  end
end
