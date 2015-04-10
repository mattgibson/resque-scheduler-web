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
