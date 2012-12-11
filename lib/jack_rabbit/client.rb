require 'jack_rabbit/connection'

module JackRabbit
  module Client
    private

    def open_connection(uri, options)
      Connection.new(uri, options)
        .set_logger(@logger)
        .open
    end

    def open_channel(connection, options)
      connection
        .channel(options)
        .set_logger(@logger)
        .open
    end
  end
end
