require 'rails_helper'

describe ResqueWeb::Plugins::ResqueScheduler::SchedulesController, type: :controller do
  routes { ResqueWeb::Plugins::ResqueScheduler::Engine.routes }

  describe 'GET index' do

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
      get :index
    end

    it 'sees the scheduled job' do
      expect(assigns(:scheduled_jobs)).to match hash_including('some_ivar_job' => hash_including('class' => 'SomeIvarJob'))
    end

    it 'excludes jobs for other envs' do
      expect(assigns(:scheduled_jobs)).to_not match hash_including('some_fancy_job' => hash_including('class' => 'SomeFancyJob'))
    end

    it 'includes job used in multiple environments' do
      expect(assigns(:scheduled_jobs)).to match hash_including('shared_env_job' => hash_including('class' => 'SomeSharedEnvJob'))
    end

  end

  describe 'POST requeue_with_params' do
    before do
      Resque.schedule = Test::RESQUE_SCHEDULE
      Resque::Scheduler.load_schedule!
    end

    it 'redirects correctly to the Resque Web overview' do
      job_name = 'job_with_params'
      log_level = 'error'

      job_config = Resque.schedule[job_name]
      args = job_config['args'].merge('log_level' => log_level)
      job_config.merge!('args' => args)

      allow(Resque::Scheduler).to receive(:enqueue_from_config).once.with(job_config)

      post :requeue_with_params, 'job_name' => job_name, 'log_level' => log_level

      expect(response).to redirect_to ResqueWeb::Engine.app.url_helpers.overview_path
    end
  end

  describe 'POST requeue' do
    before do
      Resque.schedule = Test::RESQUE_SCHEDULE
      Resque::Scheduler.load_schedule!
    end

    context 'with a job that has no defined params' do
      it 'redirects to the overview page' do
        job_name = 'job_without_params'
        allow(Resque::Scheduler).to receive(:enqueue_from_config)
          .once.with(Resque.schedule[job_name])

        post :requeue, 'job_name' => job_name
        expect(response).to redirect_to ResqueWeb::Engine.app.url_helpers.overview_path

      end
    end

    context 'with a job that has defined params' do

      it 'renders a form for the params to be entered' do
        job_name = 'job_with_params'
        post :requeue, 'job_name' => job_name
        expect(response).to render_template 'requeue-params'
      end

    end
  end

  describe 'DELETE destroy' do
    before do
      Resque.schedule = Test::RESQUE_SCHEDULE
      Resque::Scheduler.load_schedule!
    end

    context 'with a static schedule' do

      before do
        allow(Resque::Scheduler).to receive(:dynamic).and_return(false)
      end

      it 'does not delete the job' do
        params = {job_name: 'job_with_params'}
        delete :destroy, params

        msg = 'The job should not have been deleted from redis.'
        expect(Resque.fetch_schedule('job_with_params')).to be_truthy, msg
      end

    end

    context 'with a dynamic schedule' do
      before do
        allow(Resque::Scheduler).to receive(:dynamic).and_return(true)
      end

      it 'redirects to schedule page' do
        params = {job_name: 'job_with_params'}
        delete :destroy, params

        expect(response).to redirect_to resque_scheduler_engine_routes.schedules_path
      end

      it 'removes job from redis' do
        params = {job_name: 'job_with_params'}
        delete :destroy, params

        msg = 'The job was not deleted from redis.'
        expect(Resque.fetch_schedule('job_with_params')).to be_nil, msg
      end
    end
  end
end