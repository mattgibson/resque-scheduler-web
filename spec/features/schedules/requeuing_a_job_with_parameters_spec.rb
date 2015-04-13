require 'rails_helper'

feature 'requeuing a job that has defined params' do
  before do
    Resque.schedule = Test::RESQUE_SCHEDULE
    Resque::Scheduler.load_schedule!
  end

  after do
    Resque.reset_delayed_queue
    Resque.queues.each { |q| Resque.remove_queue q }
  end

  # Given I have a job which requires params in the schedule
  # When I press the requeue button
  # Then I should be presented with a form that prompts me for the params
  # When I enter the params and submit the form
  # Then I should be on the overview page
  # And I should see the job in the queue
  # When I visit the queue page
  # Then I should see the job on the page with the new params
  scenario 'I am prompted to enter the params required for the requeued job' do
    job_name = 'job_with_params'
    queue_name = 'quick'
    job_class = 'JobWithParams'

    visit resque_scheduler_engine_routes.schedules_path
    click_button "requeue_job_#{job_name}"

    fill_in 'log_level', with: 'info'
    click_button 'Queue now'

    expect(current_path).to eq ResqueWeb::Engine.app.url_helpers.overview_path
    find('.queues .queue a', text: queue_name).click

    expect(page).to have_content job_class
    expect(page).to have_css 'td.args', text: /"log_level"=>"info"/
  end
end
