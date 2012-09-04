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

    def bind_queues(channels, exchange_name, key, queue_name, options, &block)
      channels.inject(@subscriptions) do |memo,channel|
        exchange = declare_exchange(channel, exchange_name, options)
        queue =
          bind_queue(channel, exchange, queue_name, key, options).tap do |q|
            q.subscribe(SUBSCRIBE_OPTIONS.merge(options), &block)
          end
        memo.push(queue)
      end
    end

    def bind_queue(channel, exchange, name, key, options)
      channel
        .queue(name, QUEUE_OPTIONS.merge(Hash(options[:queue])))
        .tap { |q| q.bind(exchange, { routing_key: key }) }
    end

    def declare_exchange(channel, name, options)
      channel.exchange(name, EXCHANGE_OPTIONS.merge(Hash(options[:exchange])))
    end
  end
end
