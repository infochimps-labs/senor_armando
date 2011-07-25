module SenorArmando
  module Rack

    # Middleware to rescue validation errors and send them up the chain as normal non-200 responses
    class ExceptionHandler
      include Goliath::Rack::Validator

      def initialize(app)
        @app = app
      end

      def call(env)
        self.class.safely(env) do
          @app.call(env)
        end
      end

      # @param err [Goliath::Validation::Error] error to describe in response
      # @param headers [Hash] Response headers to preserve in an error response;
      #   (the Content-Length header, if any, is removed)
      def self.error_response err, headers={}
        headers.merge!({
            'Content-Type'     => "application/json",
            'X-Error-Message' => err.message,
            'X-Error-Detail'  => err.description,
          })
        headers.delete('Content-Length')
        body    = {
          "error"   => err.class.to_s.gsub(/.*::/,""),
          "message" => [err.message, err.description].compact.join(": "),
          "status"  => err.status_code
        }
        [err.status_code, headers, body.to_json]
      end

      # Execute a block of code safely.
      #
      # If the block raises any exception that derives from
      # Goliath::Validation::Error (see specifically those in
      # goliath/validation/standard_http_errors.rb), it will be turned into the
      # corresponding 4xx response with a corresponding message.
      #
      # If the block raises any other kind of error, we log it and return a
      # less-communicative 500 response.
      #
      # @example
      #   # will convert the ForbiddenError exception into a 403 response
      #   # and an uncaught error in do_something_risky! into a 500 response
      #   safely(env, headers) do
      #     raise ForbiddenError unless account_info['valid'] == true
      #     do_something_risky!
      #     [status, headers, body]
      #   end
      #
      #
      # @param env [Goliath::Env] The current request env
      # @param headers [Hash] Response headers to preserve in an error response
      #
      def self.safely(env, headers={})
        begin
          yield
        rescue Goliath::Validation::Error => err
          error_response(err, headers)
        rescue Exception => err
          env.logger.error(err.message)
          env.logger.error(err.backtrace.join("\n"))
          puts(err.message)
          puts(err.backtrace.join("\n"))
          error_response(Goliath::Validation::InternalServerError.new('Internal Server Error'), headers)
        end
      end

    end
  end
end
