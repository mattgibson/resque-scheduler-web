require 'rails_helper'

feature 'the tabs added to the resque web interface work correctly' do

  scenario 'the Schedule tab works' do
    visit ResqueWeb::Engine.app.url_helpers.overview_path
    click_link 'Schedule'
    expect(current_path).to eq resque_scheduler_engine_routes.schedules_path
  end

  scenario 'the Delayed tab works' do
    visit ResqueWeb::Engine.app.url_helpers.overview_path
    click_link 'Delayed'
    expect(current_path).to eq resque_scheduler_engine_routes.delayed_path
  end
end