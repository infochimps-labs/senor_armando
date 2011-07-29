module Goliath
  module Rack

    #
    # The strategy here is similar to that employed by EM::Multi. If you go
    # understand that first, it will help you understand this.
    #

    module AsyncBarrier
      include EventMachine::Deferrable

      # The request environment, set in the initializer
      attr_reader :env
      # The response -- will be set from the BarrierMiddleware
      attr_accessor :status, :headers, :body
      # Pool of handles for pending requests
      attr_reader :pending_requests
      # Pool of handles for sucessful requests
      attr_reader :successes
      # Pool of handles for failed requests
      attr_reader :failures

      # Called by a BarrierMiddleware to create the barrier.
      #
      # @param env [Env] The request environment
      # @return [Goliath::Rack::AsyncBarrier]
      def initialize(env)
        @env = env
        @pending_requests = Set.new
        @successes        = Set.new
        @failures         = Set.new
      end

      #
      # Virtual setter for the downstream middleware/endpoint response --
      #
      def downstream_response=(status_headers_body)
        @status, @headers, @body = status_headers_body
      end

      def accept_response(handle, succeeded, resp)
        raise "received response for a non-pending request!" if not pending_requests.include?(handle)
        pending_requests.delete(handle)
        succeeded ? (successes << resp) : (failures << resp)
      end


      def add(handle, deferred_req)
        fiber = Fiber.current
        deferred_req.callback { @responses[:callback][handle] = conn; check_progress(fiber) }
        deferred_req.errback  { @responses[:errback][handle]  = conn; check_progress(fiber) }

        @requests.push(conn)
      end

      def finished?
        pending_requests.empty?
      end

      def perform
        Fiber.yield unless finished?
      end

      alias_method :enqueue, :add

    end
  end
end
