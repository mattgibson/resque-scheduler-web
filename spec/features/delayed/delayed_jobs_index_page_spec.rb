require 'rails_helper'

feature 'seeing all the delayed jobs on the index page' do

  after do
    reset_the_resque_schedule
  end

  let(:some_time_in_the_future) { Time.now + 3600 }
  let(:some_other_time_in_the_future) { Time.now + 4600 }

  # Given there is a delayed job
  # And another delayed job enqueued at a later time
  # When I visit the delayed jobs index page
  # Then I should see the job on the page
  scenario 'delayed jobs show up on the page when at different times' do
    Resque.enqueue_at(some_time_in_the_future, SomeIvarJob)
    Resque.enqueue_at(some_other_time_in_the_future, JobWithoutParams)
    visit resque_scheduler_engine_routes.delayed_path
    expect(page).to have_content 'SomeIvarJob'
    expect(page).to have_content 'JobWithoutParams'
  end

end