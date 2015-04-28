require 'rails_helper'

feature 'Viewing the schedule page and interacting with it' do
  def visit_scheduler_page
    visit resque_scheduler_engine_routes.schedules_path
  end

  before do
    Resque::Scheduler.env = 'production'

    Resque.schedule = {
      'some_ivar_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeIvarJob',
        'args' => '/tmp',
        'rails_env' => 'production'
      },
      'some_other_job' => {
        'every' => ['1m', ['1h']],
        'queue' => 'high',
        'custom_job_class' => 'SomeOtherJob',
        'args' => {
          'b' => 'blah'
        }
      },
      'some_fancy_job' => {
        'every' => ['1m'],
        'queue' => 'fancy',
        'class' => 'SomeFancyJob',
        'args' => 'sparkles',
        'rails_env' => 'fancy'
      },
      'shared_env_job' => {
        'cron' => '* * * * *',
        'class' => 'SomeSharedEnvJob',
        'args' => '/tmp',
        'rails_env' => 'fancy, production'
      }
    }
    Resque::Scheduler.load_schedule!
    visit_scheduler_page
  end

  after do
    reset_the_resque_schedule
  end

  it 'Link to Schedule page in navigation works' do
    visit '/resque_web'
    click_link 'Schedule'
    assert page.has_css? 'h1', 'Schedule'
  end

  it 'has the correct title' do
    assert page.has_css?('h1', 'Schedule')
  end

  it 'shows the scheduled job' do
    assert page.body.include?('SomeIvarJob')
  end

  it 'excludes jobs for other envs' do
    refute page.body.include?('SomeFancyJob')
  end

  it 'includes job used in multiple environments' do
    assert page.body.include?('SomeSharedEnvJob')
  end

  it 'allows delete when dynamic' do
    allow(Resque::Scheduler).to receive(:dynamic).and_return(true)
    visit_scheduler_page

    assert page.body.include?('Delete')
  end

  it "doesn't allow delete when static" do
    allow(Resque::Scheduler).to receive(:dynamic).and_return(false)
    visit_scheduler_page

    refute page.body.include?('Delete')
  end
end
