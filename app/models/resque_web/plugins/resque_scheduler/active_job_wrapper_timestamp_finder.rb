module ResqueWeb
  module Plugins
    module ResqueScheduler
      # The way ActiveJob works breaks Resque Scheduler's method for finding
      # the timestamps when jobs have been scheduled. This is because the
      # queue name is stored as a parameter and is not accessible as an instance
      # variable or via a class method. This class is used by the controller
      # to handle the special case.
      class ActiveJobWrapperTimestampFinder
        def initialize(args)
          @args = args
        end

        def perform
          search_string = "timestamps:#{encoded_search_string}"
          Resque.instance_eval do
            redis.smembers(search_string).map do |key|
              key.tr('delayed:', '').to_i
            end
          end
        end

        def encoded_search_string
          Resque.send :encode, hashed_job
        end

        def hashed_job
          Resque.send :job_to_hash_with_queue,
                      queue_name,
                      active_job_wrapper_class_name,
                      @args
        end

        def queue_name
          @args.first['queue_name']
        end

        def active_job_wrapper_class_name
          'ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper'
        end
      end
    end
  end
end
