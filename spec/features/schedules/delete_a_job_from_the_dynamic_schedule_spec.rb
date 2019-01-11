require 'rails_helper'

feature 'deleting a job from the dynamic schedule' do
  include SharedFunctionsForFeatures

  before do
    given_there_are_two_jobs_in_the_scheduler
    and_the_schedule_is_set_up_to_be_dynamic
    when_i_visit_the_scheduler_page
  end

  scenario 'the job disappears from the UI' do
    when_i_delete_the_job_from_the_ui
    then_i_should_be_on_the_scheduler_page
    and_the_job_should_not_be_present_in_the_ui
  end

  scenario 'the other job remains in the UI' do
    when_i_delete_the_job_from_the_ui
    then_i_should_be_on_the_scheduler_page
    and_the_other_job_should_still_be_present_in_the_ui
  end

  scenario 'the job is removed from the resque backend' do
    when_i_delete_the_job_from_the_ui
    then_i_should_be_on_the_scheduler_page
    and_the_job_should_no_longer_be_present_in_the_resque_schedule
  end

  def and_the_schedule_is_set_up_to_be_dynamic
    allow(Resque::Scheduler).to receive(:dynamic).and_return(true)
  end

  def given_there_are_two_jobs_in_the_scheduler
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
    Resque::Scheduler.load_schedule!
  end

  def when_i_visit_the_scheduler_page
    visit resque_scheduler_engine_routes.schedules_path
  end

  def when_i_delete_the_job_from_the_ui
    find('#job_some_ivar_job .delete-button').click
  end

  def then_i_should_be_on_the_scheduler_page
    expect(current_path).to eq resque_scheduler_engine_routes.schedules_path
  end

  def and_the_job_should_no_longer_be_present_in_the_resque_schedule
    expect(Resque.schedule).to_not have_key 'some_ivar_job'
  end

  def and_the_other_job_should_still_be_present_in_the_ui
    expect(page).to have_css '#job_some_other_job'
  end

  def and_the_job_should_not_be_present_in_the_ui
    expect(page).to_not have_css '#job_some_ivar_job'
  end
end
