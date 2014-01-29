require 'jack_rabbit/message_header'
require 'jack_rabbit/logging'

module JackRabbit
  class Subscription
    include Logging

    DEFAULT_OPTIONS = { blocking: false }

    def initialize(channel, exchange, key, queue, options, &block)
      @channel = channel
      @exchange, @key, @queue, @options = exchange, key, queue, options
      @block = block
    end

    def declare
      queue = @channel.create_queue(@queue, @options)
      if !@exchange.empty?
        exchange = @channel.create_exchange(@exchange, @options)
        queue.bind(exchange, { routing_key: @key, arguments: @options[:arguments] })
      end
      @subscription =
        queue.subscribe(DEFAULT_OPTIONS.merge(@options)) do |meta, message|
          @block.call(MessageHeader.new(meta), message)
        end
    end
  end
end
