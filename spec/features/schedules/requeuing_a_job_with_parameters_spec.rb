require 'rails_helper'

feature 'requeuing a job that has defined params' do

  include SharedFunctionsForFeatures

  before do
    given_i_have_a_job_which_requires_params_in_the_schedule
  end

  scenario 'I am prompted to enter the params required for the requeued job' do
    when_i_visit_the_schedules_page
    and_i_requeue_the_job_with_new_params
    then_i_should_be_on_the_overview_page
    and_i_should_see_the_job_in_the_queue
    when_i_click_on_the_link_to_the_queue
    then_i_should_see_details_of_the_job_on_the_page
  end

  let(:job_name) { 'job_with_params' }
  let(:queue_name) { 'quick' }
  let(:job_class) { 'JobWithParams' }

  def given_i_have_a_job_which_requires_params_in_the_schedule
    Resque.schedule = Test::RESQUE_SCHEDULE
    Resque::Scheduler.load_schedule!
  end

  def when_i_visit_the_schedules_page
    visit resque_scheduler_engine_routes.schedules_path
  end

  def and_i_requeue_the_job_with_new_params
    click_button "requeue_job_#{job_name}"

    fill_in 'log_level', with: 'info'
    click_button 'Queue now'
  end

  def then_i_should_be_on_the_overview_page
    expect(current_path).to eq ResqueWeb::Engine.app.url_helpers.overview_path
  end

  def and_i_should_see_the_job_in_the_queue
    expect(page).to have_content "#{queue_name} 1"
  end

  def when_i_click_on_the_link_to_the_queue
    find('.queues .queue a', text: queue_name).click
  end

  def then_i_should_see_details_of_the_job_on_the_page
    expect(page).to have_content job_class
    expect(page).to have_css 'td.args', text: /"log_level"=>"info"/
  end
end
