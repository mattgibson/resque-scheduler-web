module ResqueWeb
  module Plugins
    module ResqueScheduler
      module DelayedHelper
        # Outputs the time in a human readable way.
        #
        # @example
        #   format_time(Time.at(timestamp))
        #
        # @param t [Time]
        # @return [String] A string in the following format: 2015-04-12 12:27:05 +0100
        #
        def format_time(t)
          t.strftime('%Y-%m-%d %H:%M:%S %z')
        end
      end
    end
  end
end
