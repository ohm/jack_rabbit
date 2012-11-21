$:.push(File.expand_path('../../lib', __FILE__))

require 'uri'
require 'jack_rabbit'

producer = JackRabbit::Producer.new

producer.connect(URI.parse('amqp://guest:guest@localhost:5672/'))

loop do
  puts producer.publish('jackrabbitdev', :direct, 'consumer.test', 'foo')
  sleep(1)
end
