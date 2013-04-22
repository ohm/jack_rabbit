# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jack_rabbit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'jack_rabbit'
  gem.version       = JackRabbit::VERSION
  gem.platform      = 'java'
  gem.summary       = 'Convenience wrapper around AMQP client libraries'
  gem.authors       = [ 'Sebastian Ohm' ]
  gem.email         = [ 'ohm.sebastian@gmail.com' ]
  gem.require_paths = [ 'lib' ]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_dependency('hot_bunnies', '~> 1.5.0')
end
