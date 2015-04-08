module ResqueWeb
  module Plugins
    module ResqueScheduler
      # Controller for delayed jobs. These have been added to the queue by the
      # application, so here, they can be run immediately, deleted from the
      # queue, or rescheduled.
      class DelayedController < ResqueWeb::ApplicationController
        def index
        end

        def jobs_klass
          klass = Resque::Scheduler::Util.constantize(params[:klass])
          @args = JSON.load(URI.decode(params[:args]))
          @timestamps = Resque.scheduled_at(klass, *@args)
        rescue
          @timestamps = []
        end

        def search
          @jobs = find_job(params[:search])
        end

        def cancel_now
          klass = Resque::Scheduler::Util.constantize(params['klass'])
          timestamp = params['timestamp']
          args = Resque.decode params['args']
          Resque.remove_delayed_job_from_timestamp(timestamp, klass, *args)
          redirect_to Engine.app.url_helpers.delayed_path
        end

        def clear
          Resque.reset_delayed_queue
          redirect_to Engine.app.url_helpers.delayed_path
        end

        def queue_now
          timestamp = params['timestamp'].to_i
          if timestamp > 0
            Resque::Scheduler.enqueue_delayed_items_for_timestamp(timestamp)
          end
          redirect_to ResqueWeb::Engine.app.url_helpers.overview_path
        end

        def timestamp
          @timestamp = params[:timestamp].to_i
        end

        protected

        def find_job(search_term)
          search_term.downcase!

          results = working_jobs_where_class_name_contains(search_term)
          results += delayed_jobs_where_class_name_contains(search_term)
          results + queued_jobs_where_class_name_matches(search_term)
        end

        def queued_jobs_where_class_name_matches(search_term)
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

        def working_jobs_where_class_name_contains(search_term)
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

        def delayed_jobs_where_class_name_contains(search_term)
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

        def delayed_jobs_for_timestamp(timestamp)
          Resque.delayed_timestamp_peek(timestamp,
                                        0,
                                        number_of_delayed_jobs_at(timestamp))
        end

        def number_of_delayed_jobs_at(timestamp)
          Resque.delayed_timestamp_size(timestamp)
        end

        def delayed_job_timestamps
          Resque.delayed_queue_peek(0, schedule_size)
        end

        def schedule_size
          Resque.delayed_queue_schedule_size
        end
      end
    end
  end
end
