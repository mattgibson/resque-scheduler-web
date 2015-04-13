require 'rails_helper'

describe ResqueWeb::Plugins::ResqueScheduler::DelayedController,
         type: :routing do
  routes { ResqueWeb::Plugins::ResqueScheduler::Engine.routes }

  it 'routes to POST cancel_now' do
    expected_route = 'resque_web/plugins/resque_scheduler/delayed#cancel_now'
    expect(post 'delayed/cancel_now').to route_to(expected_route)
  end
end
