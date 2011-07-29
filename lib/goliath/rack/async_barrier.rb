module Goliath
  module Rack

    #
    # The strategy here is similar to that of EM::Multi. Figuring out what goes
    # on there will help you understand this.
    #
    module AsyncBarrier
      include EventMachine::Deferrable

      # The request environment, set in the initializer
      attr_reader :env
      # The response, set by the BarrierMiddleware's downstream
      attr_accessor :status, :headers, :body
      # Pool with handles of pending requests
      attr_reader :pending_requests
      # Pool with handles of sucessful requests
      attr_reader :successes
      # Pool with handles of failed requests
      attr_reader :failures

      # @param env [Goliath::Env] The request environment
      # @return [Goliath::Rack::AsyncBarrier]
      def initialize(env)
        @env = env
        @pending_requests = Set.new
        @successes        = {}
        @failures         = {}
      end

      # Override this method in your middleware to perform any preprocessing
      # (launching a deferred request, perhaps). You must return
      # Goliath::Connection::AsyncResponse if you want processing to continue
      def pre_process
        Goliath::Connection::AsyncResponse
      end

      # Override this method in your middleware to perform any postprocessing.
      # This will only be invoked when all deferred requests (including the
      # response) have completed
      #
      # @return [Array] array contains [status, headers, body]
      def post_process
        [status, headers, body]
      end

      # Virtual setter for the downstream middleware/endpoint response
      def downstream_response=(status_headers_body)
        @status, @headers, @body = status_headers_body
      end

      # Add a deferred request to the pending pool, and set a callback to
      # #accept_response when the request completes
      def enqueue(handle, deferred_req)
        add_to_pending(handle)
        fiber = Fiber.current
        deferred_req.callback{ accept_response(handle, true,  deferred_req, fiber) }
        deferred_req.errback{  accept_response(handle, false, deferred_req, fiber) }
      end

      # On receipt of an async result,
      # * remove the tracking handle from pending_requests
      # * and file the response in either successes or failures as appropriate
      # * call the setter for that handle if it exists (accepting :shortened_url
      #   effectively calls self.shortened_url = resp)
      # * check progress -- succeeds (transferring controll) if nothing is pending.
      def accept_response(handle, resp_succ, resp, fiber=nil)
        raise "received response for a non-pending request!" if not pending_requests.include?(handle)
        pending_requests.delete(handle)
        resp_succ ? (successes[handle] = resp) : (failures[handle] = resp)
        self.send("#{handle}=", resp) if self.respond_to?("#{handle}=")
        check_progress(fiber)
      end

      # Register a pending request. If you call this from outside #enqueue, you
      # must construct callbacks that eventually invoke accept_response
      def add_to_pending(handle)
        set_deferred_status(nil) # we're not done yet, even if we were
        @pending_requests << handle
      end

      def finished?
        pending_requests.empty?
      end

      # Perform will yield (allowing other processes to continue) until all
      # pending responses complete.  You're free to enqueue responses, call
      # perform,
      def perform
        Fiber.yield unless finished?
      end

    protected

      def check_progress(fiber)
        if finished?
          succeed
          # continue processing
          fiber.resume(self) if fiber && fiber.alive? && fiber != Fiber.current
        end
      end

    end
  end
end
