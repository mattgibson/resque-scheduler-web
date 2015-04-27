# vim:fileencoding=utf-8
require 'socket'
require 'timeout'
require 'fileutils'

# This provides a Redis instance for the test environment. It manages bootup and
# shutdown etc, whilst preventing conflicts with other things that may be
# running on the same port.
class RedisInstance
  class << self
    def run_if_needed!
      run! unless @running
    end

    def run!
      ensure_redis_server_present!
      ensure_pid_directory
      reassign_redis_clients
      start_redis_server
      post_boot_waiting_and_such
      @running = true
    end

    def stop!
      $stdout.puts "Sending TERM to Redis (#{pid})..." if $stdout.tty?
      Process.kill('TERM', pid)

      @port = nil
      @running = false
      @pid = nil
    end

    def port
      @port ||= random_port
    end

    private

    def post_boot_waiting_and_such
      wait_for_pid
      puts "Booted isolated Redis on #{port} with PID #{pid}."
      wait_for_redis_boot
      at_exit { stop! } # Ensure we tear down Redis on Ctrl+C / test failure.
    end

    def ensure_redis_server_present!
      fail "** can't find `redis-server` in your path" unless redis_detected?
    end

    def redis_detected?
      system('redis-server -v')
    end

    def wait_for_redis_boot
      Timeout.timeout(10) do
        loop do
          begin
            break if Resque.redis.ping == 'PONG'
          rescue Redis::CannotConnectError
            @waiting = true
          end
        end
        @waiting = false
      end
    end

    def ensure_pid_directory
      FileUtils.mkdir_p(File.dirname(pid_file))
    end

    def reassign_redis_clients
      Resque.redis = Redis.new(
        hostname: '127.0.0.1', port: port, thread_safe: true
      )
    end

    def start_redis_server
      IO.popen('redis-server -', 'w+') do |server|
        server.write(config)
        server.close_write
      end
    end

    def pid
      @pid ||= File.read(pid_file).to_i
    end

    def wait_for_pid
      Timeout.timeout(10) do
        loop { break if File.exist?(pid_file) }
      end
    end

    def pid_file
      '/tmp/resque-scheduler-web-test.pid'
    end

    def config
      <<-EOF
        daemonize yes
        pidfile #{pid_file}
        port #{port}
      EOF
    end

    # Returns a random port in the upper (10000-65535) range.
    def random_port
      ports = (10_000..65_535).to_a
      loop do
        port = ports[rand(ports.size)]
        return port if port_available?('127.0.0.1', port)
      end
    end

    def port_available?(ip, port, seconds = 1)
      Timeout.timeout(seconds) do
        begin
          TCPSocket.new(ip, port).close
          false
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          true
        end
      end
    rescue Timeout::Error
      true
    end
  end
end
