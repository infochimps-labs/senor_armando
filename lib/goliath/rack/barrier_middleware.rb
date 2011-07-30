module Goliath
  module Rack
    #
    # Include this to enable middleware that can perform pre- and
    # post-processing, optionally having multiple responses pending.
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
    # This class creates a "barrier" helper to do that kind of "around"
    # processing. Goliath proceeds asynchronously, but will still "unwind" the
    # request by walking up the callback chain. Delegating out to the
    # AsyncBarrier also lets you carry state around -- the ban on instance
    # variables no longer applies, as each barrier is unique per request.
    #
    # @example
    #   class ShortenUrl
    #     attr_accessor :shortened_url
    #     include Goliath::Rack::AsyncBarrier
    #
    #     def pre_process
    #       target_url        = PostRank::URI.clean(env.params['url'])
    #       shortener_request = EM::HttpRequest.new('http://is.gd/create.php').aget(:query => { :format => 'simple', :url => target_url })
    #       enqueue :shortened_url, shortener_request
    #       Goliath::Connection::AsyncResponse
    #     end
    #
    #     # by the time you get here, the BarrierMiddleware will have populated
    #     # the [status, headers, body] and the shortener_request will have
    #     # populated the shortened_url attribute.
    #     def post_process
    #       if succeeded?(:shortened_url)
    #         headers['X-Shortened-URI'] = shortened_url
    #       end
    #       [status, headers, body]
    #     end
    #   end
    #
    #   class AwesomeApiWithShortening < Goliath::API
    #     use Goliath::Rack::Params
    #     use Goliath::Rack::BarrierMiddleware, ShortenUrl
    #
    #     def response(env)
    #       # ... do something awesome
    #     end
    #   end
    #
    class BarrierMiddleware
      include Goliath::Rack::Validator

      # Called by the framework to create the middleware.  Any extra args passed
      # to the use statement are sent to each barrier_klass as it is created.
      #
      # @example
      #   class AwesomeProcessor
      #     include Goliath::Rack::AsyncBarrier
      #
      #     def initialize(env, aq)
      #       @awesomeness_quotient = aq
      #       super(env)
      #     end
      #
      #     # ... define pre_process and post_process ...
      #   end
      #
      #   class AwesomeApiWithShortening < Goliath::API
      #     use Goliath::Rack::BarrierMiddleware, AwesomeProcessor, 3
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

      # This coordinates an async_barrier to process a request. We hook the
      # barrier in the middle of the async_callback chain:
      # * send the downstream response to the barrier, either directly
      #   (@app.call) or via async callback
      # * have the upstream callback chain be invoked when the barrier completes
      #
      # @param env [Goliath::Env] The goliath environment
      # @return [Array] The [status_code, headers, body] tuple
      def call(env)
        barrier =  new_barrier(env)

        barrier_resp = barrier.pre_process
        return barrier_resp if final_response?(barrier_resp)

        barrier.add_to_pending(:downstream_resp)
        hook_into_callback_chain(env, barrier)

        downstream_resp = @app.call(env)

        # pass a final response to the barrier, which will invoke the callback
        # chain at its leisure. Either way, our response is *always* async.
        if final_response?(downstream_resp)
          send_response_to_barrier(env, barrier, downstream_resp)
        end
        return Goliath::Connection::AsyncResponse
      end

      # Generate a barrier to process the request, using request env & any args
      # passed to this BarrierMiddleware at creation
      #
      # @param env [Goliath::Env] The goliath environment
      # @return [Goliath::Rack::AsyncBarrier] The barrier to process this request
      def new_barrier(env)
        @barrier_klass.new(env, *@barrier_args)
      end

      # Put barrier in the middle of the async_callback chain:
      # * save the old callback chain;
      # * have the downstream callback send results to the barrier (possibly
      #   completing it)
      # * set the old callback chain to fire when the barrier completes
      def hook_into_callback_chain(env, barrier)
        async_callback = env['async.callback']

        # The response from the downstream app is accepted by the barrier...
        downstream_callback = Proc.new{|resp| send_response_to_barrier(env, barrier, resp) }
        env['async.callback'] = downstream_callback

        # .. but the upstream chain is only invoked when the barrier completes
        invoke_upstream_chain = Proc.new do
          barrier_resp = safely(env){ barrier.post_process }
          async_callback.call(barrier_resp)
        end
        barrier.callback(&invoke_upstream_chain)
        barrier.errback(&invoke_upstream_chain)
      end

      def final_response?(resp)
        resp != Goliath::Connection::AsyncResponse
      end

      def send_response_to_barrier(env, barrier, resp)
        safely(env){ barrier.accept_response(:downstream_resp, true, resp) }
      end
    end
  end
end
