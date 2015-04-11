require 'spec_helper'

require File.expand_path("../dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path(
                                             '../../test/dummy/db/migrate',
                                             __FILE__
                                           )]
ActiveRecord::Migrator.migrations_paths << File.expand_path(
  '../../db/migrate',
  __FILE__
)

require 'rspec/rails'


# So we can access the Engine class and its path helpers
$LOAD_PATH.unshift File.dirname(File.expand_path(__FILE__)) + '/../lib'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end

# Travis fails to find Redis without this, although it works locally.
# No idea why.
# RedisInstance.run!
Resque.redis = Redis.new(
  hostname: '127.0.0.1', port: RedisInstance.port, thread_safe: true
)

