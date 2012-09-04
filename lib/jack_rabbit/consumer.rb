require 'hot_bunnies'
require 'jack_rabbit/message_header'

module JackRabbit
  class Consumer
    EXCHANGE_OPTIONS  = { durable: true, type: :direct }
    QUEUE_OPTIONS     = { durable: true }
    SUBSCRIBE_OPTIONS = { blocking: false }

    def initialize
      @connections   = []
      @channels      = []
      @subscriptions = []
    end

    def connect(uris)
      uris.inject(@connections) { |memo,uri| memo.push(open_connection(uri)) }
    end

    def subscribe(exchange, key, queue, options = {}, &block)
      channels = open_channels(options[:prefetch])
      bind_queues(channels, exchange, key, queue, options) do |meta, message|
        block.call(MessageHeader.new(meta), message)
      end
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
            channel.prefetch = prefetch if prefetch
          end
        memo.push(channel)
      end
    end

    def bind_queues(channels, exchange_name, key, queue, options, &block)
      channels.inject(@subscriptions) do |memo,channel|
        exchange = channel.exchange(exchange_name, EXCHANGE_OPTIONS)
        queue =
          channel.queue(queue, QUEUE_OPTIONS).tap do |q|
            q.bind(exchange, { routing_key: key })
          end
        memo.push(queue.subscribe(SUBSCRIBE_OPTIONS.merge(options), &block))
      end
    end
  end
end
