require 'hot_bunnies'
require 'jack_rabbit/channel'

module JackRabbit
  class Connection
    DEFAULT_OPTIONS = { connection_timeout: 5, heartbeat_interval: 5 }

    def initialize(uri, options)
      @uri, @options = uri, options
      @channels = []
    end

    def open
      open_connection(@uri, @options)
      self
    end

    def close
      @connection.close
    end

    def channel(options)
      channel = Channel.new(self, options)
      @channels << channel
      channel.open
      channel
    end

    def reopen
      open_connection(@uri, @options)
      @channels.each { |channel| channel.reopen }
    end

    def create_channel
      @connection.create_channel
    end

    private

    def open_connection(uri, options)
      connection = HotBunnies.connect(connection_options(uri).merge(options))
      connection.add_shutdown_listener { |_reason| reopen }
      @connection = connection
    end

    def connection_options(uri)
      DEFAULT_OPTIONS.merge({
        host: uri.host,
        pass: uri.password,
        port: uri.port,
        user: uri.user,
        vhost: uri.path
      })
    end
  end
end
