module Goliath
  module Rack
    #
    # Include this to enable middleware that can perform post-processing.
    #
    # For internal reasons, you can't do the following as you would in Rack:
    #
    #   def call(env)
    #     # ... do pre-processing
    #     status, headers, body = @app.call(env)
    #     new_body = make_totally_awesome(body) ## !! BROKEN !!
    #     [status, headers, new_body]
    #   end
    #
    # +use+ing this sets up a "barrier" helper to do that kind of "around"
    # processing. Goliath proceed asynchronously, but still "unwind" the request
    # by walking up the callback chain. Delegating out to the AsyncBarrier also
    # lets you carry state around -- the ban on instance variables no longer
    # applies, as the barrier is created for exactly that request.
    #
    # @example
    #   class AwesomeBarrier
    #     include Goliath::Rack::AsyncBarrier
    #
    #     def pre_process
    #       env['awesomness_quotient'] = 3
    #       # the return value of pre_process is irrelevant
    #     end
    #
    #     def post_process(env, status, headers, body, awesomness_quotient)
    #       new_body = make_totally_awesome(body, awesomness_quotient)
    #       [status, headers, new_body]
    #     end
    #   end
    #
    module BarrierMiddleware
      # Called by the framework to create the barrier middleware.
      #
      # @example
      #   class MyAsyncBarrier < Goliath::Rack::MultiReceiver
      #     # ... define pre_process and post_process ...
      #   end
      #
      #   class AsyncAroundwareDemoMulti < Goliath::API
      #     use Goliath::Rack::AsyncAroundware, MyAsyncBarrier
      #     # ... stuff ...
      #   end
      #
      # @param app [#call] the downstream app
      # @param barrier_klass a class that quacks like a
      #   Goliath::Rack::AsyncBarrier and an EM::Deferrable
      # @param *args [Array] extra args to pass to the barrier
      # @return [Goliath::Rack::AsyncMiddleware]
      def initialize app, barrier_klass, *args
        @app = app
        @barrier_klass = barrier_klass
        @barrier_args  = args
      end

      #
      # However, you will notice that we execute the post_process method in the
      # default return case. If the validations fail later in the middleware
      # chain before your classes response(env) method is executed, the response
      # will come back up through the chain normally and be returned.
      #
      # To do preprocessing, override this method in your subclass and invoke
      # super(env) as the last line.  Any extra arguments will be made available
      # to the post_process method.
      #
      # ... downstream @app.call either
      # * returns a result directly (perhaps an error occured, or perhaps the
      #   middleware short-circuits, like Goliath::Rack::Heartbeat
      # * or returns the 'Goliath::Connection::AsyncResponse', in which case
      #   we will receive the actual response to process later via callback
      #
      # @param env [Goliath::Env] The goliath environment
      # @return [Array] The [status_code, headers, body] tuple
      def call(env, *args)
        barrier =  new_barrier(env)

        hook_into_callback_chain(env, barrier)

        barrier_resp = barrier.pre_process
        if final_response?(barrier_resp)
          return barrier_resp
        else
          barrier.add_to_pending :response
        end

        downstream_resp = @app.call(env)
        
        # pass a final response to the barrier, which will invoke the callback
        # chain at its leisure. Either way, our response is *always* async.
        if final_response?(downstream_resp)
          barrier.accept_response(downstream_resp)
        end
        return Goliath::Connection::AsyncResponse
      end

      def final_response?(resp)
        resp != Goliath::Connection::AsyncResponse
      end

      # Store the previous async.callback into async_cb and redefines it to be
      # our own. When the asynchronous response is done, Goliath can "unwind"
      # the request by walking up the callback chain.
      #
      # put barrier in the middle of the async_callback chain:
      # * save the old callback chain;
      # * put the barrier in as the new async_callback;
      # * when the barrier completes, invoke the old callback chain
      def hook_into_callback_chain(env, barrier)
        async_callback = env['async.callback']

        # The response from the downstream app is accepted by the barrier...
        downstream_callback = Proc.new do |status, headers, body|
          safely(env){ barrier.accept_response(status, headers, body) }
        end
        env['async.callback'] = downstream_callback

        # But the upstream callback is only invoked when the barrier completes
        invoke_upstream_callback = Proc.new do
          safely(env){ async_callback.call(barrier.post_process) }
        end
        barrier.callback(&invoke_upstream_callback)
        barrier.errback(&invoke_upstream_callback)
      end

      include Goliath::Rack::Validator
      def do_postprocess(env, async_callback, barrier)
        safely(env) do
          result_for_upstream = barrier.post_process
          async_callback.call(result_for_upstream)
        end
      end
      
      # Generates the barrier to actually process the request, giving it
      # the request env & any args passed to this BarrierMiddleware at creation
      def new_barrier(env)
        @barrier_klass.new(env, *@barrier_args)
      end
      
      # Override this method in your middleware to perform any
      # postprocessing. Note that this can be called in the asynchronous case
      # (walking back up the middleware async.callback chain), or synchronously
      # (in the case of a validation error, or if a downstream middleware
      # supplied a direct response).
      def post_process(env, status, headers, body)
        [status, headers, body]
      end
    end
  end
end
