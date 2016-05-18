require 'rails_helper'

feature 'cancelling a delayed job' do
  include SharedFunctionsForFeatures

  scenario 'cancelling the job from the search page' do
    given_there_is_a_delayed_job
    when_i_search_for_the_delayed_job
    and_i_cancel_the_job
    then_i_should_be_on_the_delayed_jobs_page
    and_the_job_should_not_be_present_on_the_page
  end

  def and_i_cancel_the_job
    click_button 'Cancel'
  end

  def when_i_search_for_the_delayed_job
    visit resque_scheduler_engine_routes.delayed_path
    fill_in 'search', with: 'some'
    click_button 'Search'
  end

  def and_the_job_should_not_be_present_on_the_page
    expect(page).to_not have_content 'SomeIvarJob'
  end
end
