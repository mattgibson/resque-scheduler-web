def reset_the_resque_schedule
  Resque.reset_delayed_queue
  Resque.queues.each { |q| Resque.remove_queue q }
  Resque.schedule = {}
  Resque::Scheduler.load_schedule!
  Resque::Scheduler.env = 'test'
end
