require 'rails_helper'

feature 'cancelling a delayed job' do

  let(:some_time_in_the_future) { Time.now + 3600 }

  scenario 'cancelling the job from the search page' do
    given_there_is_a_delayed_job
    when_i_search_for_the_delayed_job
    and_i_cancel_the_job
    then_i_should_be_on_the_delayed_job_page
    and_the_job_should_not_be_present_on_the_page
  end

  def given_there_is_a_delayed_job
    Resque.enqueue_at(some_time_in_the_future, SomeIvarJob)
  end

  def and_i_cancel_the_job
    click_button 'Cancel'
  end

  def when_i_search_for_the_delayed_job
    visit resque_scheduler_engine_routes.delayed_path
    fill_in 'search', with: 'some'
    click_button 'Search'
  end

  def then_i_should_be_on_the_delayed_job_page
    expect(current_path).to eq resque_scheduler_engine_routes.delayed_path
  end

  def and_the_job_should_not_be_present_on_the_page
    expect(page).to_not have_content 'SomeIvarJob'
  end
end