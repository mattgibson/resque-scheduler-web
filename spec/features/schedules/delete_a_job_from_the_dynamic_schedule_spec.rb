require 'rails_helper'

feature 'deleting a job from the dynamic schedule' do

  def visit_scheduler_page
    visit resque_scheduler_engine_routes.schedules_path
  end

  before do
    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp',
        'rails_env' => 'test'
      },
      'some_other_job' => {
        'every' => ['1m', ['1h']],
        'queue' => 'high',
        'custom_job_class' => 'SomeOtherJob',
        'rails_env' => 'test',
        'args' => {
          'b' => 'blah'
        }
      }
    }
    allow(Resque::Scheduler).to receive(:dynamic).and_return(true)
    Resque::Scheduler.load_schedule!
    visit_scheduler_page
  end

  after do
    Resque.reset_delayed_queue
    Resque.queues.each { |q| Resque.remove_queue q }
    Resque.schedule = {}
    Resque::Scheduler.env = 'test'
  end

  # Given there is a job in the scheduler
  # And the schedule is set up to be dynamic
  # When I delete the job from the UI
  # Then I should be on the schedule page
  # And the job should no longer be present
  scenario 'the job disappears from the UI' do
    find('#job_some_ivar_job .delete-button').click
    expect(current_path).to eq resque_scheduler_engine_routes.schedules_path
    expect(page).to_not have_css '#job_some_ivar_job'
  end

  # Given there are two jobs in the scheduler
  # And the schedule is set up to be dynamic
  # When I delete the job from the UI
  # Then I should be on the schedule page
  # And the other job should still be present
  scenario 'the other job remains in the UI' do
    find('#job_some_ivar_job .delete-button').click
    expect(current_path).to eq resque_scheduler_engine_routes.schedules_path
    expect(page).to have_css '#job_some_other_job'
  end

  # Given there is a job in the scheduler
  # And the schedule is set up to be dynamic
  # When I delete the job from the UI
  # Then I should be on the schedule page
  # And the job should no longer be present in the Resque schedule
  scenario 'the job is removed from the resque backend' do
    find('#job_some_ivar_job .delete-button').click
    expect(current_path).to eq resque_scheduler_engine_routes.schedules_path
    expect(Resque.schedule).to_not have_key 'some_ivar_job'
  end
end
