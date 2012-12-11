$:.push(File.expand_path('../../lib', __FILE__))

require 'uri'
require 'jack_rabbit'
require 'logger'
require 'thread'

$stdout.sync = true

Thread.abort_on_exception = true

subscriptions = [
  # exchange         key              queue
  [ 'jackrabbitdev', 'consumer.test', 'consumer.test', {} ]
]

consumer = JackRabbit::Consumer.new(Logger.new($stdout))

consumer.connect([
  URI.parse('amqp://guest:guest@localhost:5672/')
])

subscriptions.each do |exchange, key, queue, options|
  consumer.subscribe(exchange, key, queue, options) do |header, message|
    puts [ header, message ].inspect
  end
end
