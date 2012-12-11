$:.push(File.expand_path('../../lib', __FILE__))

require 'uri'
require 'jack_rabbit'
require 'thread'

Thread.abort_on_exception = true

producer = JackRabbit::Producer.new

producer.connect(URI.parse('amqp://guest:guest@localhost:5672/'))

loop do
  puts producer.publish('jackrabbitdev', :direct, 'consumer.test', 'foo')
  sleep(1)
end
