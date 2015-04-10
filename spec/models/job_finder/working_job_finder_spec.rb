
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
  end

  it 'finds a working job when the search term matches' do
    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder.new('going')
    assert_equal 'OngoingJob', finder.find_jobs.first['class']
  end

  it 'does not find a working job when the search term does not match' do
    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder.new('donkey')
    assert_empty finder.find_jobs
  end

  it 'adds the queue name to the returned jobs' do
    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder.new('going')
    assert_equal 'quick', finder.find_jobs.first['queue']
  end

  it 'sets the where_at value to "working" for the returned jobs' do
    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder.new('going')
    assert_equal 'working', finder.find_jobs.first['where_at']
  end
end