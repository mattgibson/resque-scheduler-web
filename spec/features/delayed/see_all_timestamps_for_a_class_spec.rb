require 'rails_helper'

feature 'seeing all of the timestamps where a class is delayed' do

  include SharedFunctionsForFeatures

  scenario 'viewing the timestamps page with no params' do
    given_there_is_a_delayed_job
    when_i_visit_the_delayed_jobs_page
    and_i_click_on_the_link_to_see_all_the_timestamps_for_that_job
    then_i_should_be_on_the_delayed_class_page
    and_i_should_see_the_timestamp_on_the_page
  end

  scenario 'viewing the timestamps page with params' do
    given_there_is_a_delayed_job_with_params
    when_i_visit_the_delayed_jobs_page
    and_i_click_on_the_link_to_see_all_the_timestamps_for_that_job
    then_i_should_be_on_the_delayed_class_page_with_params
    and_i_should_see_the_timestamp_on_the_page
  end

  scenario 'viewing the timestamps page with activejob' do
    given_there_is_a_delayed_job_with_active_job
    when_i_visit_the_delayed_jobs_page
    and_i_click_on_the_link_to_see_all_the_timestamps_for_that_job
    and_i_should_see_the_timestamp_on_the_page
  end

  def and_i_click_on_the_link_to_see_all_the_timestamps_for_that_job
    click_link 'All schedules'
  end

  def then_i_should_be_on_the_delayed_class_page
    expect(current_path).to eq resque_scheduler_engine_routes.delayed_job_class_path klass: 'SomeIvarJob'
  end

  def then_i_should_be_on_the_delayed_class_page_with_params
    expect(current_path).to eq resque_scheduler_engine_routes.delayed_job_class_path klass: 'JobWithParams'
  end

  def and_i_should_see_the_timestamp_on_the_page
    expect(page).to have_content some_time_in_the_future
  end

  def given_there_is_a_delayed_job_with_params
    Resque.enqueue_at(some_time_in_the_future, JobWithParams, argument: 'thingy')
  end

  def given_there_is_a_delayed_job_with_active_job
    ActiveJobTest.set(wait_until: some_time_in_the_future).perform_later
  end

end
