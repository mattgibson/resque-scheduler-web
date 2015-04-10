module ResqueWeb
  module Plugins
    module ResqueScheduler
      class JobFinder
        # This class finds working jobs that Resque is currently processing
        class WorkingJobFinder

          attr_accessor :search_term

          def initialize(search_term)
            @search_term = search_term
          end

          def find_jobs
            workers_with_jobs_that_match_search_term.collect do |w|
              w.job['payload'].merge(
                'queue' => w.job['queue'],
                'where_at' => 'working'
              )
            end
          end

          def workers_with_jobs_that_match_search_term
            all_working_jobs.select do |w|
              w.job &&
                w.job['payload'] &&
                w.job['payload']['class'].downcase.include?(search_term)
            end
          end

          protected

          def all_working_jobs
            [*Resque.working]
          end
        end
      end
    end
  end
end