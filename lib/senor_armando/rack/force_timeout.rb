require 'spec_helper'
Settings.define :force_timeout, :description => 'Force timeout after this many milliseconds', :type => Integer, :default => nil

require 'senor_armando/goliath_extensions'

module SenorArmando
  module Rack
    #
    # Force a timeout after
    #
    #
    class ForceTimeout
      include Goliath::Rack::ComponentName

      # Called by the framework to create the middleware.
      #
      # @param app [Proc] The application
      # @return [Goliath::Rack::AsyncMiddleware]
      def initialize(app)
        @app = app
      end

      # Store the previous async.callback into async_cb and redefines it to be
      # our own. When the asynchronous response is done, Goliath can "unwind"
      # the request by walking up the callback chain.
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
      # @param env [Goliath::Env] The goliath environment
      # @return [Array] The [status_code, headers, body] tuple
      def call(env, *args)
        async_cb = env['async.callback']

        env['async.callback'] = Proc.new do |status, headers, body|
          unless env['force_timeout_callback_ran']
            env['force_timeout_callback_ran'] = true
            headers.merge({ header_slug('Force-Timeout') => 'nornmal' })
            async_cb.call([status, headers, body])
          end
        end

        timeout = 100.to_f

        EM.add_timer(timeout / 1000) do
          p "Timer!!"
          unless env['force_timeout_callback_ran']
            env['force_timeout_callback_ran'] = true
            err = Goliath::Validation::RequestTimeoutError.new("Request exceeded #{timeout.to_i} ms")
            async_cb.call(Goliath::Rack::Validator.error_response(err))
          end
        end

        status, headers, body = @app.call(env)

        if status == Goliath::Connection::AsyncResponse.first
          p "Back!!!"
          env['force_timeout_callback_ran'] = true
        end
        [status, headers, body]
      end
    end
  end
end
