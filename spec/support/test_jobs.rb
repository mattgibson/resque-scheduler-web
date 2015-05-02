require 'active_job'

# Allows us to test that we can find working jobs
class OngoingJob
  def self.queue
    :quick
  end

  def self.perform
    sleep 5
  end
end

# Generic job to use as a base class for the test jobs below.
class SomeJob
  def self.perform(_repo_id, _path)
  end
end

# Test job
class SomeQuickJob < SomeJob
  @queue = :quick
end

# Test job
class SomeIvarJob < SomeJob
  @queue = :ivar
end

# Job for tests where we put it into more than one environment and test that it
# only shows up for one.
class SomeSharedEnvJob < SomeJob
  def self.queue
    :shared_job
  end
end

# Job for tests, where we expect there to be parameters provided.
class JobWithParams
  @queue = :quick

  def self.perform(*args)
    @args = args
  end
end

JobWithoutParams = Class.new(JobWithParams) do
  @queue = :quick
end

# Allows us to test whether jobs added via the ActiveJob wrapper are correctly
# handled.
class ActiveJobTest < ActiveJob::Base
  queue_as :test_queue

  def self.queue
    queue_name
  end

  def perform
  end
end

# Test module
module Foo
  # Test class
  class Bar
    def self.queue
      'bar'
    end
  end
end

# This is just a container for a dummy schedule.
module Test
  RESQUE_SCHEDULE = {
    'job_without_params' => {
      'cron' => '* * * * *',
      'class' => 'JobWithoutParams',
      'args' => {
        'host' => 'localhost'
      },
      'rails_env' => 'production'
    },
    'job_with_params' => {
      'every' => '1m',
      'class' => 'JobWithParams',
      'args' => {
        'host' => 'localhost'
      },
      'parameters' => {
        'log_level' => {
          'description' => 'The level of logging',
          'default' => 'warn'
        }
      }
    }
  }
end
