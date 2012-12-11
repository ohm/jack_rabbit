$:.push(File.expand_path('../../lib', __FILE__))

require 'uri'
require 'jack_rabbit'
require 'logger'
require 'thread'

$stdout.sync = true

Thread.abort_on_exception = true

producer = JackRabbit::Producer.new(Logger.new($stdout))

producer.connect(URI.parse('amqp://guest:guest@localhost:5672/'))

n = 0
loop do
  message = (n += 1).to_s
  producer.publish('jackrabbitdev', :direct, 'consumer.test', message)
  puts(message)
  sleep(1)
end
