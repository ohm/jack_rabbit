require 'jack_rabbit/subscription'
require 'jack_rabbit/logging'

module JackRabbit
  class Channel
    include Logging

    EXCHANGE_OPTIONS = { durable: true, type: :direct }

    QUEUE_OPTIONS = { durable: true }

    def initialize(connection, options)
      @connection, @options = connection, options
      @subscriptions = []
    end

    def open
      open_channel(@connection, @options)
      self
    end

    def close
      @channel.close
    end

    def subscribe(exchange, key, queue, options, &block)
      sub = Subscription.new(self, exchange, key, queue, options, &block)
      @subscriptions << sub
      sub.declare
      sub
    end

    def reopen
      open_channel(@connection, @options)
      @subscriptions.each { |sub| sub.declare }
    end

    def create_exchange(name, options)
      @channel.exchange(name, EXCHANGE_OPTIONS.merge(options))
    end

    def create_queue(name, options)
      @channel.queue(name, QUEUE_OPTIONS.merge(options))
    end

    private

    def open_channel(connection, options)
      debug('opening channel...')
      channel = connection.create_channel
      channel.prefetch(options[:prefetch]) if options[:prefetch]
      channel.add_shutdown_listener { |_reason| connection.reconnect }
      @channel = channel
    end
  end
end
