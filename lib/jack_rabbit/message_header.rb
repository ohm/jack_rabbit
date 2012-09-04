module JackRabbit
  class MessageHeader
    attr_reader :metadata

    def initialize(metadata)
      @metadata = metadata
    end

    def content_type
      @metadata.properties.content_type
    end

    private

    def method_missing(method, *args, &block)
      metadata.send(method, *args, &block)
    end
  end
end
