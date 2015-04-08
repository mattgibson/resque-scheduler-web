# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque/scheduler/web/version'

Gem::Specification.new do |spec|
  spec.name          = "resque-scheduler-web"
  spec.version       = Resque::Scheduler::Web::VERSION
  spec.authors       = ["Matt Gibson"]
  spec.email         = ["downrightlies@gmail.com"]
  spec.summary       = 'This gem provides tabs in Resque Web for managing '\
                       'Resque Scheduler.'
  spec.description   = 'Use this if you want to move to the new Resque Web '\
                       'plugin architecture via the resque-web gem, rather '\
                       'than the Sinatra-based approach that is bundled with '\
                       'Resque 1.x'
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rails', '~> 4.2.0'
  spec.add_development_dependency 'resque-web'
  spec.add_development_dependency 'resque-scheduler'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'sass' # Avoids non-thread-safe error.

end
