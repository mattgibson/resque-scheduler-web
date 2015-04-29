require 'rails_helper'

feature 'the tabs added to the resque web interface work correctly' do
  scenario 'the Schedule tab works' do
    when_i_visit_the_resque_web_overview_page
    and_i_follow_the_schedule_link
    then_i_should_be_on_the_schedules_page
  end

  scenario 'the Delayed tab works' do
    when_i_visit_the_resque_web_overview_page
    when_i_follow_the_delayed_link
    then_i_should_be_on_the_delayed_page
  end

  def when_i_visit_the_resque_web_overview_page
    visit ResqueWeb::Engine.app.url_helpers.overview_path
  end

  def and_i_follow_the_schedule_link
    click_link 'Schedule'
  end

  def then_i_should_be_on_the_schedules_page
    expect(current_path).to eq resque_scheduler_engine_routes.schedules_path
  end

  def when_i_follow_the_delayed_link
    click_link 'Delayed'
  end

  def then_i_should_be_on_the_delayed_page
    expect(current_path).to eq resque_scheduler_engine_routes.delayed_path
  end

end
