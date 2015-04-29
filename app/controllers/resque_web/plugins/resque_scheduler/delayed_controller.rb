module ResqueWeb
  module Plugins
    module ResqueScheduler
      # Controller for delayed jobs. These have been added to the queue by the
      # application, so here, they can be run immediately, deleted from the
      # queue, or rescheduled.
      class DelayedController < ResqueWeb::ApplicationController
        # GET /delayed
        def index
          @start = params[:start].to_i
          @number_to_show = 20
          @total_number_of_delayed_jobs = Resque.delayed_queue_schedule_size
          @timestamps = Resque.delayed_queue_peek(@start, @number_to_show)
        end

        # GET /delayed/jobs/:klass
        # Shows us all of the jobs of this type, with these args. Accessed by
        # clicking the 'All schedules' link next to a delayed job.
        def jobs_klass
          klass = Resque::Scheduler::Util.constantize(params[:klass])
          @args = params[:args] ? JSON.load(URI.decode(params[:args])) : []

          # ActiveJob hack. The wrapper class does not know what queue the
          # wrapped class wants to use, so we need to tell Resque Scheduler
          # the queue, rather than have it use Resque's internal guessing
          # mechanism.
          if klass.to_s == 'ActiveJob::QueueAdapters::ResqueAdapter::JobWrapper'
            queue_name = @args.first['queue_name']
            hashed_job = Resque.send :job_to_hash_with_queue, queue_name, klass, @args
            search = Resque.send :encode, hashed_job
            @timestamps = Resque.instance_eval do
              redis.smembers("timestamps:#{search}").map do |key|
                key.tr('delayed:', '').to_i
              end
            end
          else
            @timestamps = Resque.scheduled_at(klass, *@args)
          end
        rescue
          @timestamps = []
        end

        # POST /delayed/search
        def search
          @jobs = JobFinder.new(params[:search]).find_jobs
        end

        # POST /delayed/cancel_now
        def cancel_now
          klass = Resque::Scheduler::Util.constantize(params['klass'])
          timestamp = params['timestamp']
          args = Resque.decode params['args']
          Resque.remove_delayed_job_from_timestamp(timestamp, klass, *args)
          redirect_to Engine.app.url_helpers.delayed_path
        end

        # POST /delayed/clear
        def clear
          Resque.reset_delayed_queue
          redirect_to Engine.app.url_helpers.delayed_path
        end

        # POST /delayed/queue_now
        def queue_now
          timestamp = params['timestamp'].to_i
          if timestamp > 0
            Resque::Scheduler.enqueue_delayed_items_for_timestamp(timestamp)
          end
          redirect_to ResqueWeb::Engine.app.url_helpers.overview_path
        end

        # GET /delayed/:timestamp
        def timestamp
          @timestamp = params[:timestamp].to_i
          @start = params[:start].to_i
          @size = Resque.delayed_timestamp_size(@timestamp)
          @jobs = Resque.delayed_timestamp_peek(@timestamp, @start, 20)
        end
      end
    end
  end
end
