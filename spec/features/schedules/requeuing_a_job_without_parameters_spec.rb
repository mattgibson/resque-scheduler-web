require 'rails_helper'

feature 'requeuing a job that has no params' do
  before do
    Resque.schedule = {
      'job_without_params' => {
        'cron' => '* * * * *',
        'class' => 'JobWithoutParams',
        'args' => {
          'host' => 'localhost'
        },
        'rails_env' => 'test'
      }
    }
    Resque::Scheduler.load_schedule!
  end

  after do
    reset_the_resque_schedule
  end

  # Given I have a job which requires params in the schedule
  # When I press the requeue button
  # Then I should be on the overview page
  # And I should see the job in the queue
  # When I visit the queue page
  # Then I should see the job on the page with the new params
  scenario 'I am prompted to enter the params required for the requeued job' do
    job_name = 'job_without_params'
    queue_name = 'quick'
    job_class = 'JobWithoutParams'

    visit resque_scheduler_engine_routes.schedules_path
    click_button "requeue_job_#{job_name}"

    expect(current_path).to eq ResqueWeb::Engine.app.url_helpers.overview_path
    expect(page).to have_content "#{queue_name} 1"

    find('.queues .queue a', text: queue_name).click

    expect(page).to have_content job_class
  end
end
