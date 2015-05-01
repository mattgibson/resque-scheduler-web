module SharedFunctionsForFeatures

  def self.included(base)
    base.instance_eval do
      let(:some_time_in_the_future) { Time.now + 3600 }
      let(:some_other_time_in_the_future) { Time.now + 4600 }

      after do
        reset_the_resque_schedule
      end
    end
  end

  def when_i_visit_the_delayed_jobs_page
    visit resque_scheduler_engine_routes.delayed_path
  end

  def then_i_should_be_on_the_delayed_jobs_page
    expect(current_path).to eq resque_scheduler_engine_routes.delayed_path
  end

  def given_there_are_two_delayed_jobs_enqueued_at_different_times
    Resque.enqueue_at(some_time_in_the_future, SomeIvarJob)
    Resque.enqueue_at(some_other_time_in_the_future, JobWithoutParams)
  end

  def given_there_is_a_delayed_job
    Resque.enqueue_at(some_time_in_the_future, SomeIvarJob)
  end

  def then_i_should_be_on_the_overview_page
    expect(current_path).to eq ResqueWeb::Engine.app.url_helpers.overview_path
  end

  def and_i_should_see_the_job_in_the_queue
    expect(page).to have_content "#{queue_name} 1"
  end

  def when_i_click_through_to_the_queue_page
    find('.queues .queue a', text: queue_name).click
  end

  def then_i_should_see_the_details_of_the_job_on_the_page
    expect(page).to have_content job_class
  end
end

