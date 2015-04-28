require 'rails_helper'

feature 'seeing a summary of the delayed jobs for a timestamp on the index' do

  after do
    reset_the_resque_schedule
  end

  let(:some_time_in_the_future) { Time.now + 3600 }
  let(:some_other_time_in_the_future) { Time.now + 4600 }

  # Given there is a delayed job
  # And another delayed job enqueued at the same time
  # When I visit the delayed jobs index page
  # Then I should see the jobs on the page as a summary
  # When I click through to the details page
  # Then I should see the details of the jobs
  scenario 'delayed jobs show up on the page when at the same times' do
    Resque.enqueue_at(some_time_in_the_future, JobWithParams, { argument: 'thingy' })
    Resque.enqueue_at(some_time_in_the_future, JobWithoutParams)
    visit resque_scheduler_engine_routes.delayed_path
    expect(page).to have_css '.job-count', text: '2'
    click_link 'see details'
    expect(page).to have_content 'JobWithParams'
    expect(page).to have_content '"argument"=>"thingy"'
    expect(page).to have_content 'JobWithoutParams'
  end

end