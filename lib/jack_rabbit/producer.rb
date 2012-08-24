require 'hot_bunnies'

module JackRabbit
  class Producer
    EXCHANGE_OPTIONS = { auto_delete: false, durable: true }

    def connect(uri)
      @channel = (@connection = open_connection(uri)).create_channel
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

    def open_connection(uri)
      HotBunnies.connect(
        host: uri.host,
        pass: uri.password,
        port: uri.port,
        user: uri.user
      )
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
