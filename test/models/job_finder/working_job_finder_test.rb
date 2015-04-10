require_relative '../../test_helper'

class WorkingJobFinderTest < ActiveSupport::TestCase

  setup do
    Resque.enqueue(OngoingJob)
    @worker_thread = Thread.new do
      worker = Resque::Worker.new '*'
      worker.term_child = 1
      worker.work 0.1
    end
    sleep 0.2
  end

  teardown do
    @worker_thread.kill
  end

  test 'finds a working job when the search term matches' do
    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder.new('going')
    assert_equal 'OngoingJob', finder.find_jobs.first['class']
  end

  test 'does not find a working job when the search term does not match' do
    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder.new('donkey')
    assert_empty finder.find_jobs
  end

  test 'adds the queue name to the returned jobs' do
    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder.new('going')
    assert_equal 'quick', finder.find_jobs.first['queue']
  end

  test 'sets the where_at value to "working" for the returned jobs' do
    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder::WorkingJobFinder.new('going')
    assert_equal 'working', finder.find_jobs.first['where_at']
  end
end