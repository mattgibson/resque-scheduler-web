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

RedisInstance.run_if_needed!


