require 'rails_helper'

feature 'seeing a summary of the delayed jobs for a timestamp on the index' do

  scenario 'delayed jobs show up on the page when at the same times' do
    given_there_are_two_delayed_jobs_enqueued_at_the_same_time
    when_i_visit_the_delayed_jobs_page
    then_i_should_see_the_delayed_jobs_on_the_page_as_summary
    when_i_click_through_to_the_details_page
    then_i_should_see_the_details_of_the_jobs
  end

  scenario 'jobs on the delayed page all have a link to their timestamp page' do
    given_there_is_a_delayed_job
    when_i_visit_the_delayed_jobs_page
    when_i_click_on_the_timestamp_next_to_the_job
    then_i_should_be_on_the_timestamps_page
  end

  after do
    reset_the_resque_schedule
  end

  let(:some_time_in_the_future) { Time.now + 3600 }

  def then_i_should_be_on_the_timestamps_page
    expected_path = resque_scheduler_engine_routes.timestamp_path(
      timestamp: some_time_in_the_future.to_i
    )
    expect(current_path).to eq expected_path
  end

  def when_i_click_on_the_timestamp_next_to_the_job
    all('.timestamp-link a').first.click
  end

  def given_there_is_a_delayed_job
    Resque.enqueue_at(some_time_in_the_future, SomeIvarJob)
  end

  def given_there_are_two_delayed_jobs_enqueued_at_the_same_time
    Resque.enqueue_at(some_time_in_the_future, JobWithParams, argument: 'thingy')
    Resque.enqueue_at(some_time_in_the_future, JobWithoutParams)
  end

  def when_i_visit_the_delayed_jobs_page
    visit resque_scheduler_engine_routes.delayed_path
  end

  def then_i_should_see_the_delayed_jobs_on_the_page_as_summary
    expect(page).to have_css '.job-count', text: '2'
  end

  def when_i_click_through_to_the_details_page
    click_link 'see details'
  end

  def then_i_should_see_the_details_of_the_jobs
    expect(page).to have_content 'JobWithParams'
    expect(page).to have_content '"argument"=>"thingy"'
    expect(page).to have_content 'JobWithoutParams'
    expect(page).to have_content some_time_in_the_future
  end
end