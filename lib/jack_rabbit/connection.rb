require 'hot_bunnies'
require 'jack_rabbit/channel'
require 'jack_rabbit/logging'

module JackRabbit
  class Connection
    include Logging

    DEFAULT_OPTIONS = { connection_timeout: 5, heartbeat_interval: 5 }

    def initialize(uri, options)
      @uri, @options = uri, options.merge(connection_options(uri))
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

    def reopen(reason)
      debug('%s, reconnecting...' % reason.inspect)
      open_connection(@uri, @options)
      @channels.each { |channel| channel.reopen }
    end

    def create_channel
      @connection.create_channel
    end

    private

    def open_connection(uri, options)
      begin
        info('connecting to %s:%d...' % [ uri.host, uri.port ])
        connection = HotBunnies.connect(options)
      rescue Java::JavaNet::ConnectException
        sleep(1)
        retry
      end
      connection.add_shutdown_listener { |reason| reopen(reason) }
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
