require_relative '../../../../../../app/models/resque_web/plugins/'\
                   'resque_scheduler/job_finder/working_job_finder'

describe ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder do
  before do
    Resque.enqueue(OngoingJob)
    @worker_thread = Thread.new do
      worker = Resque::Worker.new '*'
      worker.term_child = 1
      worker.work 0.1
    end
    sleep 0.2
  end

  after do
    @worker_thread.kill
    Resque.reset_delayed_queue
    Resque.queues.each { |q| Resque.remove_queue q }
  end

  it 'finds a working job when the search term matches' do
    finder = described_class.new('going')
    expect(finder.find_jobs.first['class']).to eq 'OngoingJob'
  end

  it 'does not find a working job when the search term does not match' do
    finder = described_class.new('donkey')
    expect(finder.find_jobs).to be_empty
  end

  it 'adds the queue name to the returned jobs' do
    finder = described_class.new('going')
    expect(finder.find_jobs.first['queue']).to eq 'quick'
  end

  it 'sets the where_at value to "working" for the returned jobs' do
    finder = described_class.new('going')
    expect(finder.find_jobs.first['where_at']).to eq 'working'
  end
end
