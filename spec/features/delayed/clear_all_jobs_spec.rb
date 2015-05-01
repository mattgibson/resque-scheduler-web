require 'rails_helper'

feature 'clearing all of the delayed jobs' do

  include SharedFunctionsForFeatures

  scenario 'clearing the jobs from the delayed index' do
    given_there_are_two_delayed_jobs_enqueued_at_different_times
    when_i_visit_the_delayed_jobs_page
    and_i_click_the_clear_all_jobs_button
    then_i_should_be_on_the_delayed_jobs_page
    and_i_should_not_see_any_jobs_on_the_page
  end

  def and_i_should_not_see_any_jobs_on_the_page
    expect(page).to_not have_content 'SomeIvarJob'
    expect(page).to_not have_content 'JobWithoutParams'
  end

  def and_i_click_the_clear_all_jobs_button
    click_button 'Clear All Delayed Jobs'
  end

end