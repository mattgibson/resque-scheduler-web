require 'rails_helper'

describe ResqueWeb::Plugins::ResqueScheduler::DelayedController,
         type: :controller do
  routes { ResqueWeb::Plugins::ResqueScheduler::Engine.routes }

  let(:some_time_in_the_future) { Time.now + 3600 }

  after do
    reset_the_resque_schedule
  end

  describe 'GET index' do
    it 'includes delayed jobs timestamp' do
      Resque.enqueue_at(some_time_in_the_future, SomeIvarJob)
      get :index
      expect(assigns(:timestamps)).to include(some_time_in_the_future.to_i)
    end
  end

  describe 'POST cancel_now' do
    it 'redirects to delayed index' do
      post :cancel_now
      expect(response).to redirect_to delayed_path
    end
  end

  describe 'POST clear' do
    it 'redirects to delayed index' do
      post :clear
      expect(response).to redirect_to delayed_path
    end
  end

  describe 'GET jobs_klass' do
    shared_examples 'a delayed job class request' do
      it 'is a 200' do
        expect(response).to be_success
      end

      it 'see the scheduled job timestamp' do
        expect(assigns(:timestamps)).to include(some_time_in_the_future.to_i)
      end
    end

    before do
      Resque.enqueue_at(some_time_in_the_future, klass, 'foo', 'bar')

      params = { klass: klass.to_s, args: URI.encode(%w(foo bar).to_json) }
      get :jobs_klass, params
    end

    context 'with a normal class' do
      let(:klass) { SomeIvarJob }
      it_behaves_like 'a delayed job class request'
    end

    context 'with a namespaced class' do
      let(:klass) { Foo::Bar }
      it_behaves_like 'a delayed job class request'
    end
  end

  describe 'GET search' do
    shared_examples 'a successful search request' do
      it 'is a 200' do
        expect(response).to be_success
      end

      it 'see the scheduled job timestamp' do
        expect(assigns(:jobs)).to \
          include(hash_including 'class' => 'SomeIvarJob')
      end
    end

    context 'with a delayed job scheduled for the future' do
      before do
        Resque.enqueue_at(some_time_in_the_future, SomeIvarJob)
        post :search, 'search' => 'ivar'
      end

      it_behaves_like 'a successful search request'
    end

    context 'with a job in the queue now' do
      before do
        Resque.enqueue(SomeIvarJob)
        post :search, 'search' => 'ivar'
      end

      it_behaves_like 'a successful search request'
    end
  end

  describe 'POST queue_now' do
    it 'redirects to overview' do
      post :queue_now
      expect(response.location).to include('overview') # In parent engine
    end
  end

  describe 'GET timestamp' do
    it 'succeeds' do
      get :timestamp, timestamp: '1234567890'
      expect(response).to be_success
    end
  end
end
