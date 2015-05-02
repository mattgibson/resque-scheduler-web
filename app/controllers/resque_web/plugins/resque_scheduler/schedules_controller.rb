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
          @scheduled_jobs = scheduled_jobs_in_alphabetical_order
        end

        # DELETE /schedule
        def destroy
          Resque.remove_schedule(params[:job_name]) if Resque::Scheduler.dynamic
          redirect_to Engine.app.url_helpers.schedules_path
        end

        # POST /schedule/requeue
        def requeue
          @job_name = params[:job_name]
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
          config = Resque.schedule[params[:job_name]]
          new_config = original_config_merged_with_submitted_params(config)
          Resque::Scheduler.enqueue_from_config(new_config)
          redirect_to ResqueWeb::Engine.app.url_helpers.overview_path
        end

        protected

        def original_config_merged_with_submitted_params(config)
          existing_config_args = config['args'] || config[:args] || {}
          new_config_args = existing_config_args.merge(submitted_params_for_job)
          config.merge('args' => new_config_args)
        end

        # Build args hash from post data (removing the job name)
        def submitted_params_for_job
          params.reject do |key, _value|
            %w(job_name action controller).include?(key)
          end
        end

        def jobs_in_this_env
          Resque.schedule.select { |name| scheduled_in_this_env?(name) }
        end

        def scheduled_jobs_in_alphabetical_order
          jobs_in_this_env.keys.sort.inject({}) do |jobs, job_name|
            jobs.merge(job_name => Resque.schedule[job_name])
          end
        end
      end
    end
  end
end
