require_relative '../test_helper'

class JobFinderTest < ActiveSupport::TestCase

  teardown do
    Resque.reset_delayed_queue
    Resque.queues.each { |q| Resque.remove_queue q }
  end

  test 'returning an empty result set with a nil search term' do
    Resque.enqueue(SomeQuickJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new(nil)
    assert_empty finder.find_jobs
  end

  test 'does not find a scheduled job that does not match' do
    t = Time.now + 60
    Resque.enqueue_at(t, SomeIvarJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('donkey')
    assert_empty finder.find_jobs
  end

  test 'finds a matching scheduled job' do
    t = Time.now + 60
    Resque.enqueue_at(t, SomeIvarJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('ivar')
    assert_equal 'SomeIvarJob', finder.find_jobs.first['class']
  end

  test 'sets "where_at" to "delayed" for the delayed scheduled jobs' do
    t = Time.now + 60
    Resque.enqueue_at(t, SomeIvarJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('ivar')
    assert_equal 'delayed', finder.find_jobs.first['where_at']
  end

  test 'sets the timestamp for the delayed scheduled jobs' do
    t = Time.now + 60
    Resque.enqueue_at(t, SomeIvarJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('ivar')
    assert_equal t.to_i, finder.find_jobs.first['timestamp']
  end


  test 'should find matching queued job' do
    Resque.enqueue(SomeQuickJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('quick')
    assert_equal 'SomeQuickJob', finder.find_jobs.first['class']
  end

  test 'adds the queue name to the returned queued jobs' do
    Resque.enqueue(SomeQuickJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('quick')
    assert_equal 'quick', finder.find_jobs.first['queue']
  end

  test 'sets "where_at" to "queued" for the returned queued jobs' do
    Resque.enqueue(SomeQuickJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('quick')
    assert_equal 'queued', finder.find_jobs.first['where_at']
  end

  test 'does not find a queued job that does not match' do
    Resque.enqueue(SomeQuickJob)

    finder = ResqueWeb::Plugins::ResqueScheduler::JobFinder.new('donkey')
    assert_empty finder.find_jobs
  end

  test 'includes working jobs' do

  end

end