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
    allow(Resque::Scheduler).to receive(:dynamic).and_return(false)
    Resque::Scheduler.load_schedule!
    visit_scheduler_page
  end

  after do
    Resque.reset_delayed_queue
    Resque.queues.each { |q| Resque.remove_queue q }
    Resque.schedule = {}
    Resque::Scheduler.env = 'test'
  end

  scenario 'the delete button is not present when the schedule is static' do
    visit resque_scheduler_engine_routes.schedules_path
    expect(page).to_not have_css '#job_some_ivar_job .delete-button'
  end

end
