# Resque::Scheduler::Web

This gem provides tabs in Resque Web for managing Resque Scheduler. It uses the
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


## Contributing

1. Fork it ( https://github.com/mattgibson/resque-scheduler-web/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
