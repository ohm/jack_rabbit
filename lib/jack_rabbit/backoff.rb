module JackRabbit
  module Backoff
    MAX = 16 # seconds

    def with_backoff(exception, f = ->(n) { n < MAX ? 2**n : MAX }, &block)
      n = 0
      begin
        yield
      rescue exception
        sleep(n = f[n])
        retry
      end
    end
  end
end
