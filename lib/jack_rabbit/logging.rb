module JackRabbit
  module Logging
    TAG = '[jack_rabbit] '

    def set_logger(logger)
      @logger = logger
      self
    end

    private

    def debug(message)
      log(:debug, message)
    end

    def info(message)
      log(:info, message)
    end

    def log(severity, message)
      @logger.send(severity, TAG + message) if @logger
    end
  end
end
