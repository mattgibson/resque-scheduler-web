require 'resque/scheduler/server'

module ResqueWeb
  module Plugins
    module ResqueScheduler
      # Controller for the schedule. If it is dynamic, then the actions allow
      # the jobs to be destroyed. Otherwise, the jobs can be manually queued
      # for immediate execution.
      class SchedulesController < ResqueWeb::ApplicationController
        include Resque::Scheduler::Server::HelperMethods

        # GET /schedule
        def index
          Resque.reload_schedule! if Resque::Scheduler.dynamic
          jobs_in_this_env = Resque.schedule.select do |name|
            scheduled_in_this_env?(name)
          end
          keys = jobs_in_this_env.keys.sort
          @scheduled_jobs = keys.inject({}) do |jobs, job_name|
            jobs.merge(job_name => Resque.schedule[job_name])
          end
        end

        # DELETE /schedule
        def destroy
          if Resque::Scheduler.dynamic
            job_name = params['job_name'] || params[:job_name]
            Resque.remove_schedule(job_name)
          end
          redirect_to Engine.app.url_helpers.schedules_path
        end

        # POST /schedule/requeue
        def requeue
          @job_name = params['job_name'] || params[:job_name]
          config = Resque.schedule[@job_name]
          @parameters = config['parameters'] || config[:parameters]
          if @parameters
            render 'requeue-params'
          else
            Resque::Scheduler.enqueue_from_config(config)
            redirect_to ResqueWeb::Engine.app.url_helpers.overview_path
          end
        end

        # POST /schedule/requeue_with_params
        def requeue_with_params
          job_name = params['job_name'] || params[:job_name]
          config = Resque.schedule[job_name]
          # Build args hash from post data (removing the job name)
          submitted_args = params.reject do |key, _value|
            %w(job_name action controller).include?(key)
          end

          # Merge constructed args hash with existing args hash for
          # the job, if it exists
          config_args = config['args'] || config[:args] || {}
          config_args = config_args.merge(submitted_args)

          # Insert the args hash into config and queue the resque job
          config = config.merge('args' => config_args)
          Resque::Scheduler.enqueue_from_config(config)
          redirect_to ResqueWeb::Engine.app.url_helpers.overview_path
        end
      end
    end
  end
end
