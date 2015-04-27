require 'resque_web'

module ResqueWeb
  module Plugins
    module ResqueScheduler
      # Main engine class for the Resque Scheduler Web plugin.
      class Engine < ::Rails::Engine
        isolate_namespace ResqueWeb::Plugins::ResqueScheduler
      end

      # Draws the routes for the engine.
      Engine.routes do
        get 'schedule', to: 'schedules#index', as: 'schedules'
        post 'schedule/requeue', to: 'schedules#requeue', as: 'requeue'
        post 'schedule/requeue_with_params',
             to: 'schedules#requeue_with_params',
             as: 'requeue_with_params'
        delete 'schedule', to: 'schedules#destroy', as: 'schedule'

        get 'delayed', to: 'delayed#index', as: 'delayed'
        get 'delayed/jobs/:klass',
            to: 'delayed#jobs_klass',
            as: 'delayed_job_class'
        post 'delayed/search', to: 'delayed#search', as: 'delayed_search'
        get 'delayed/:timestamp', to: 'delayed#timestamp', as: 'timestamp'
        post 'delayed/queue_now', to: 'delayed#queue_now', as: 'queue_now'
        post '/delayed/cancel_now', to: 'delayed#cancel_now', as: 'cancel_now'
        post '/delayed/clear', to: 'delayed#clear', as: 'clear'
      end

      # provides the path where the engine will live. This is appended after
      # the main resque-web path.
      #
      # @return [String]
      def self.engine_path
        '/scheduler'
      end

      # Tells Resque web what extra tabs to ass to the main navigation at the
      # top of the resque-web interface.
      #
      # @return [Array]
      def self.tabs
        [
          {
            'schedule' => Engine.app.url_helpers.schedules_path,
            'delayed' => Engine.app.url_helpers.delayed_path
          }
        ]
      end
    end
  end
end
