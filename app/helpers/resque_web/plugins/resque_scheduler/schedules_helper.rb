module ResqueWeb
  module Plugins
    module ResqueScheduler
      # Helper methods for the schedule UI
      module SchedulesHelper
        # Tells us whether this job is scheduled for e.g. the production env.
        # Jobs for other environments may be in Redis but should be ignored.
        #
        # @param [String] name
        # @return [true, false]
        def scheduled_in_this_env?(name)
          return true if Resque.schedule[name]['rails_env'].nil?
          rails_env(name).split(/[\s,]+/).include?(Resque::Scheduler.env)
        end

        # Returns the Rails env for the Resque schedule
        #
        # @param [String] name
        # @return [String]
        def rails_env(name)
          Resque.schedule[name]['rails_env']
        end

        # Outputs a human readable string showing the schedule for a job when it
        # it configured for every X interval.
        #
        # @param [Array] every
        # @return [String]
        def schedule_interval_every(every)
          every = [*every]
          s = 'every: ' << every.first

          return s unless every.length > 1

          s << ' ('
          meta = every.last.map do |key, value|
            "#{key.to_s.gsub(/_/, ' ')} #{value}"
          end
          s << meta.join(', ') << ')'
        end

        # Outputs a human readable string for the UI, showing when the job is
        # scheduled.
        #
        # @param [Hash] config Config hash for one job
        # @return [String]
        def schedule_interval(config)
          if config['every']
            schedule_interval_every(config['every'])
          elsif config['cron']
            'cron: ' + config['cron'].to_s
          else
            'Not currently scheduled'
          end
        end

        # Retrieves the class name of the job from the job config and returns it
        #
        # @param [Hash] config
        # @return [String]
        def schedule_class(config)
          if config['class'].nil? && !config['custom_job_class'].nil?
            config['custom_job_class']
          else
            config['class']
          end
        end

        # Returns the name of the queue that a given class uses.
        #
        # @param [String] class_name
        # @return [String]
        def queue_from_class_name(class_name)
          Resque.queue_from_class(
            Resque::Scheduler::Util.constantize(class_name)
          )
        end
      end
    end
  end
end
