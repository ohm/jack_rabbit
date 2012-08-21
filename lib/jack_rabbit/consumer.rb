require 'hot_bunnies'

module JackRabbit
  class Consumer
    EXCHANGE_OPTIONS = { durable: true, type: :direct }
    QUEUE_OPTIONS    = { durable: true }
    SUBSCRIBE_OPTIONS= { ack: true, blocking: false }

    def initialize
      @connections   = []
      @channels      = []
      @subscriptions = []
    end

    def connect(uris)
      uris.inject(@connections) do |memo,uri|
        memo.push(open_connection(uri))
      end
    end

    def subscribe(exchange_name, routing_key, prefetch, &block)
      channels = open_channels(prefetch)
      bind_queues(channels, exchange_name, routing_key, &block)
    end

    def disconnect
      @subscriptions.each(&:shutdown!)
      (@channels + @connections).each(&:close)
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

    def open_channels(prefetch)
      @connections.inject(@channels) do |memo,connection|
        channel =
          connection.create_channel.tap do |channel|
            channel.prefetch = prefetch
          end
        memo.push(channel)
      end
    end

    def bind_queues(channels, exchange_name, routing_key, &block)
      channels.inject(@subscriptions) do |memo,channel|
        exchange = channel.exchange(exchange_name, EXCHANGE_OPTIONS)
        queue =
          channel.queue(routing_key, QUEUE_OPTIONS).tap do |q|
            q.bind(exchange, { routing_key: routing_key })
          end
        memo.push(queue.subscribe(SUBSCRIBE_OPTIONS, &block))
      end
    end
  end
end
