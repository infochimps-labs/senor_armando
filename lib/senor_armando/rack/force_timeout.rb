Settings.define :force_timeout, :description => 'Force timeout after this many milliseconds', :type => Integer, :default => nil

module SenorArmando
  module Rack
    #
    # Force a timeout after
    #
    #
    class ForceTimeout
      include Goliath::Rack::AsyncMiddleware

      #
      #
      #
      def call(env)
        EM.add_timer(1000)
        super(env, true)
      end

      #
      # This could be called for the following reasons:
      # 1. directly from #call, because a downstream middleware returned directly.
      # 2. in the async_callback chain.
      # 3. from the timeout callback
      #
      def post_process(env, status, headers, body, should_succeed)
        if not should_succeed
          raise Goliath::Validation::RequestTimeoutError, "Failing"
        end
        [status, headers, body]
      end

    end
  end
end
