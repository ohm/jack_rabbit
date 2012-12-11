require 'jack_rabbit/connection'

module JackRabbit
  class Consumer
    def connect(uris, options = {})
      @connections = uris.map { |uri| Connection.new(uri, options).open }
    end

    def subscribe(exchange, key, queue, options = {}, &block)
      @connections.each do |connection|
        connection
          .channel(options)
          .subscribe(exchange, key, queue, options, &block)
      end
    end

    def disconnect
      @connections.each { |connection| connection.close }
    end
  end
end
