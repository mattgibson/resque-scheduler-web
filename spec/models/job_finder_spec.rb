require_relative '../../app/models/resque_web/plugins/resque_scheduler/job_finder'

describe ResqueWeb::Plugins::ResqueScheduler::JobFinder do

  let(:non_matching_finder) { ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('donkey') }

  after do
    Resque.reset_delayed_queue
    Resque.queues.each { |q| Resque.remove_queue q }
  end

  context 'with a scheduled job queued in the future' do

    let(:time_in_future) { Time.now + 60 }
    let(:matching_finder) { ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('ivar') }

    before do
      Resque.enqueue_at(time_in_future, SomeIvarJob)
    end

    it 'does not find a scheduled job that does not match' do
      expect(non_matching_finder.find_jobs).to be_empty
    end

    it 'finds a matching scheduled job' do
      expect(matching_finder.find_jobs.first['class']).to eq 'SomeIvarJob'
    end

    it 'sets "where_at" to "delayed" for the delayed scheduled jobs' do
      expect(matching_finder.find_jobs.first['where_at']).to eq 'delayed'
    end

    it 'sets the timestamp for the delayed scheduled jobs' do
      expect(matching_finder.find_jobs.first['timestamp']).to eq time_in_future.to_i
    end
  end

  context 'with a job currently in the queue' do

    let(:matching_finder) { ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('quick') }

    before do
      Resque.enqueue(SomeQuickJob)
    end

    it 'returns an empty result set with a nil search term' do
      finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new(nil)
      expect(finder.find_jobs).to be_empty
    end

    it 'should find matching queued job' do
      expect(matching_finder.find_jobs.first['class']).to eq 'SomeQuickJob'
    end

    it 'adds the queue name to the returned queued jobs' do
      expect(matching_finder.find_jobs.first['queue']).to eq 'quick'
    end

    it 'sets "where_at" to "queued" for the returned queued jobs' do
      expect(matching_finder.find_jobs.first['where_at']).to eq 'queued'
    end

    it 'does not find a queued job that does not match' do
      expect(non_matching_finder.find_jobs).to be_empty
    end
  end

end