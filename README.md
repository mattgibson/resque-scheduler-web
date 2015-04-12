# Resque::Scheduler::Web

[![Gem Version](https://badge.fury.io/rb/resque-scheduler-web.svg)](http://badge.fury.io/rb/resque-scheduler-web)
[![Code Climate](https://codeclimate.com/github/mattgibson/resque-scheduler-web/badges/gpa.svg)](https://codeclimate.com/github/mattgibson/resque-scheduler-web)
[![Test Coverage](https://codeclimate.com/github/mattgibson/resque-scheduler-web/badges/coverage.svg)](https://codeclimate.com/github/mattgibson/resque-scheduler-web)
[![Inline docs](http://inch-ci.org/github/mattgibson/resque-scheduler-web.svg?branch=master)](http://inch-ci.org/github/mattgibson/resque-scheduler-web)
[![Dependency Status](https://gemnasium.com/mattgibson/resque-scheduler-web.svg)](https://gemnasium.com/mattgibson/resque-scheduler-web)
[![Build Status](https://travis-ci.org/mattgibson/resque-scheduler-web.svg?branch=master)](https://travis-ci.org/mattgibson/resque-scheduler-web)

This gem provides tabs in [Resque Web](https://github.com/resque/resque-web)
for managing [Resque Scheduler](https://github.com/resque/resque-scheduler). It uses the
new Rails Engine approach, rather than the old Sinatra one.

## Installation

Add this line to your application's Gemfile:

    gem 'resque-scheduler-web'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-scheduler-web

## Usage

The gem will automatically add the correct tabs, provided you have the Resque
Web engine mounted like this in routes.rb:

    mount ResqueWeb::Engine => 'admin/resque_web'

## Running the tests

    cd resque-scheduler-web
    bundle exec rake

## Contributing

1. Fork it ( https://github.com/mattgibson/resque-scheduler-web/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## Acknowledgements

The original code and tests for this gem were taken from the Resque Scheduler gem's
Sinatra interface, and subsequently adapted into a Rails engine. Kudos and
thanks to the [original](https://github.com/resque/resque-scheduler/commits/master/lib/resque/scheduler/server.rb)
[authors](https://github.com/resque/resque-scheduler/commits/e0e91aa238c51db12794755430a7411c6ad1bfca/lib/resque_scheduler/server.rb).
