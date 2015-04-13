module ResqueWeb
  module Plugins
    module ResqueScheduler
      class JobFinder
        # This class finds working jobs that Resque is currently processing
        class WorkingJobFinder

          # The terms that the user entered.
          attr_accessor :search_term

          # The search term will be used to match against the class name of any
          # jobs that are currently being processed by any of the workers.
          #
          # @param search_term [String]
          def initialize(search_term)
            @search_term = search_term
          end

          # Finds all jobs that match the search term provided when the class
          # was instantiated.
          #
          # [
          #   {
          #     'class' => 'SomeClass',
          #     'queue' => 'some_queue',
          #     'where_at' => 'working'
          #   }
          # ]
          #
          # @return [Array] Returns an array of hashes.
          #
          def find_jobs
            workers_with_jobs_that_match_search_term.collect do |w|
              w.job['payload'].merge(
                'queue' => w.job['queue'],
                'where_at' => 'working'
              )
            end
          end

          protected

          def workers_with_jobs_that_match_search_term
            all_working_jobs.select do |w|
              w.job &&
                w.job['payload'] &&
                w.job['payload']['class'].downcase.include?(search_term)
            end
          end

          def all_working_jobs
            [*Resque.working]
          end
        end
      end
    end
  end
end