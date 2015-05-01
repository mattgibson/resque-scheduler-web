require 'rails_helper'

feature 'Sending a delayed job to the queue for immediate execution' do

  include SharedFunctionsForFeatures

  let(:queue_name) { 'ivar' }
  let(:job_class) { 'SomeIvarJob' }

  scenario 'Pressing the queue button sends the job to the queue immediately' do
    given_there_is_a_delayed_job
    when_i_visit_the_delayed_jobs_page
    and_i_press_the_queue_now_button
    then_i_should_be_on_the_overview_page
    and_i_should_see_the_job_in_the_queue
    when_i_click_through_to_the_queue_page
    then_i_should_see_the_details_of_the_job_on_the_page
    when_i_visit_the_delayed_jobs_page
    then_i_should_not_see_any_delayed_jobs
  end

  def and_i_press_the_queue_now_button
    click_button 'Queue now'
  end

  def then_i_should_not_see_any_delayed_jobs
    expect(page).to have_content 'There are no delayed jobs'
  end
end