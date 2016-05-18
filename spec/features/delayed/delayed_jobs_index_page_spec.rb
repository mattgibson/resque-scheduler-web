require 'rails_helper'

feature 'seeing all the delayed jobs on the index page' do
  include SharedFunctionsForFeatures

  scenario 'delayed jobs show up on the page when at different times' do
    given_there_are_two_delayed_jobs_enqueued_at_different_times
    when_i_visit_the_delayed_jobs_page
    then_i_should_see_the_details_of_both_jobs_on_the_page
  end

  def then_i_should_see_the_details_of_both_jobs_on_the_page
    expect(page).to have_content 'SomeIvarJob'
    expect(page).to have_content 'JobWithoutParams'
    expect(page).to have_content some_time_in_the_future
    expect(page).to have_content some_other_time_in_the_future
  end
end
