# Allows us to test that we can find working jobs
class OngoingJob
  def self.queue
    :quick
  end

  def self.perform
    sleep 5
  end
end

class SomeJob
  def self.perform(_repo_id, _path)
  end
end

class SomeQuickJob < SomeJob
  @queue = :quick
end

class SomeIvarJob < SomeJob
  @queue = :ivar
end

module Foo
  class Bar
    def self.queue
      'bar'
    end
  end
end

