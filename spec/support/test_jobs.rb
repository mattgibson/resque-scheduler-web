# Allows us to test that we can find working jobs
class OngoingJob
  def self.queue
    :quick
  end

  def self.perform
    sleep 5
  end
end

class SomeJob
  def self.perform(_repo_id, _path)
  end
end

class SomeQuickJob < SomeJob
  @queue = :quick
end

class SomeIvarJob < SomeJob
  @queue = :ivar
end

class SomeSharedEnvJob < SomeJob
  def self.queue
    :shared_job
  end
end

class JobWithParams
  @queue = :quick

  def self.perform(*args)
    @args = args
  end
end

JobWithoutParams = Class.new(JobWithParams)


module Foo
  class Bar
    def self.queue
      'bar'
    end
  end
end

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



