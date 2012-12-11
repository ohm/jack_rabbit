require 'jack_rabbit/message_header'

module JackRabbit
  class Subscription
    DEFAULT_OPTIONS = { blocking: false }

    def initialize(channel, exchange, key, queue, options, &block)
      @channel = channel
      @exchange, @key, @queue, @options = exchange, key, queue, options
      @block = block
    end

    def declare
      exchange = @channel.create_exchange(@exchange, @options)
      queue = @channel.create_queue(@queue, @options)
      queue.bind(exchange, { routing_key: @key })
      @subscription =
        queue.subscribe(DEFAULT_OPTIONS.merge(@options)) do |meta, message|
          @block.call(MessageHeader.new(meta), message)
        end
    end
  end
end
