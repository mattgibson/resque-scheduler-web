require 'rails_helper'

feature 'Viewing the schedule page and interacting with it' do

  include SharedFunctionsForFeatures

  before do
    given_the_resque_scheduler_is_using_the_production_environment
    and_there_are_several_jobs_in_the_schedule
    when_i_visit_the_scheduler_page
  end

  scenario 'the page has the correct title' do
    then_the_page_should_have_the_correct_title
  end

  scenario 'the index shows the scheduled job' do
    then_the_page_should_have_the_class_name_of_the_job_in_this_env
  end

  scenario 'the index excludes jobs for other envs' do
    then_the_page_should_not_have_the_name_of_jobs_from_other_envs
  end

  scenario 'the index includes job used in multiple environments' do
    then_the_page_should_have_the_name_of_jobs_in_both_this_and_other_envs
  end

  def given_the_resque_scheduler_is_using_the_production_environment
    Resque::Scheduler.env = 'production'
  end

  def and_there_are_several_jobs_in_the_schedule
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
  end

  def when_i_visit_the_resque_web_home_page
    visit '/resque_web'
  end

  def and_i_click_the_schedule_link
    click_link 'Schedule'
  end

  def then_the_page_should_have_the_correct_title
    assert page.has_css?('h1', 'Schedule')
  end

  def then_the_page_should_have_the_class_name_of_the_job_in_this_env
    assert page.body.include?('SomeIvarJob')
  end

  def then_the_page_should_not_have_the_name_of_jobs_from_other_envs
    refute page.body.include?('SomeFancyJob')
  end

  def then_the_page_should_have_the_name_of_jobs_in_both_this_and_other_envs
    assert page.body.include?('SomeSharedEnvJob')
  end

  def when_i_visit_the_scheduler_page
    visit resque_scheduler_engine_routes.schedules_path
  end

end
