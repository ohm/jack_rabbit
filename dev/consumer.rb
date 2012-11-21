$:.push(File.expand_path('../../lib', __FILE__))

require 'uri'
require 'jack_rabbit'

subscriptions = [
  # exchange         key              queue
  [ 'jackrabbitdev', 'consumer.test', 'consumer.test', {} ]
]

consumer = JackRabbit::Consumer.new

consumer.connect([ URI.parse('amqp://guest:guest@localhost:5672/') ])

subscriptions.each do |exchange, key, queue, options|
  consumer.subscribe(exchange, key, queue, options) do |header, message|
    puts [ header, message ].inspect
  end
end
