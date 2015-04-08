module ResqueWeb
  module Plugins
    module ResqueScheduler
      # This class exists to find jobs which match a search term. They may be
      # being processed, in the queue, or delayed.
      class JobFinder

        attr_accessor :search_term

        def initialize(search_term)
          @search_term = search_term.downcase!
          @search_term ||= ''
        end

        def find_jobs
          results = working_jobs_where_class_name_contains_search_term
          results += delayed_jobs_where_class_name_contains_search_term
          results + queued_jobs_where_class_name_matches_search_term
        end

        def working_jobs_where_class_name_contains_search_term
          [].tap do |results|
            work = all_working_jobs.select do |w|
              w.job && w.job['payload'] &&
                w.job['payload']['class'].downcase.include?(search_term)
            end
            work.each do |w|
              results += [
                w.job['payload'].merge(
                  'queue' => w.job['queue'], 'where_at' => 'working'
                )
              ]
            end
          end
        end

        def all_working_jobs
          [*Resque.working]
        end

        def delayed_jobs_where_class_name_contains_search_term
          delayed_job_timestamps.inject([]) do |dels, timestamp|
            delayed_jobs_for_timestamp(timestamp).each do |job|
              if job['class'].downcase.include?(search_term)
                job.merge!('where_at' => 'delayed')
                job.merge!('timestamp' => timestamp)
                dels << job
              end
            end
          end
        end

        def delayed_job_timestamps
          Resque.delayed_queue_peek(0, schedule_size)
        end

        def schedule_size
          Resque.delayed_queue_schedule_size
        end

        def delayed_jobs_for_timestamp(timestamp)
          Resque.delayed_timestamp_peek(timestamp,
                                        0,
                                        number_of_delayed_jobs_at(timestamp))
        end

        def number_of_delayed_jobs_at(timestamp)
          Resque.delayed_timestamp_size(timestamp)
        end

        def queued_jobs_where_class_name_matches_search_term
          Resque.queues.inject([]) do |results, queue|
            results + queued_jobs_from_queue(queue).select do |j|
              j['class'].downcase.include?(search_term) && j.merge!('queue' => queue, 'where_at' => 'queued')
            end
          end
        end


        def queued_jobs_from_queue(queue)
          bits = Resque.peek(queue, 0, Resque.size(queue))
          if bits.is_a? Array
            bits
          else
            [bits]
          end
        end

      end
    end
  end
end