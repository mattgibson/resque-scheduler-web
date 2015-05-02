require 'rails_helper'

feature 'deleting a job from the dynamic schedule' do
  include SharedFunctionsForFeatures

  scenario 'the delete button is not present when the schedule is static' do
    given_there_are_some_jobs_in_the_schedule
    and_the_schedule_is_set_to_be_static
    when_i_visit_the_scheduler_page
    then_there_should_not_be_a_delete_button_for_the_job
  end

  def given_there_are_some_jobs_in_the_schedule
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

  def and_the_schedule_is_set_to_be_static
    allow(Resque::Scheduler).to receive(:dynamic).and_return(false)
  end

  def then_there_should_not_be_a_delete_button_for_the_job
    expect(page).to_not have_css '#job_some_ivar_job .delete-button'
  end

  def when_i_visit_the_scheduler_page
    visit resque_scheduler_engine_routes.schedules_path
  end
end
