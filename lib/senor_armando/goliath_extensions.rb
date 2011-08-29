require 'gorillib/string/inflections'
module Goliath
  module Rack

    module ComponentName
      def header_slug(key)
        dasherized_name = app_name.gsub(/^[^\w]+/, '-').underscore.split(/[_\-]/).map(&:capitalize).join('-')
        "X-#{dasherized_name}-#{key}"
      end

      def component_name
        self.class.to_s.demodulize
      end

      def app_name
        Settings.app_name || Goliath::Application.app_class.to_s.demodulize
      end
    end

    module UnwindBody
      def unwind_body(body)
        body = [body] if body.respond_to?(:to_str)
        body = body.to_ary.join()
      end
    end

    module AsyncMiddleware
      include ComponentName
      include UnwindBody
    end

    #
    # make Tracer respect the header name
    #

    class Tracer
      def initialize(app, header_name=nil)
        super(app)
        @header_name = header_name || self.class.to_s.demodulize
      end
      def post_process(env, status, headers, body)
        extra = { header_slug(@header_name) => env.trace_stats.collect{|s| s.join(': ')}.join(', ')}
        env.logger.info env.trace_stats.collect{|s| s.join(':')}.join(', ')
        [status, headers.merge(extra), body]
      end
    end

    module Validator
      module_function

      # @param err [Goliath::Validation::Error] error to describe in response
      # @param headers [Hash] Response headers to preserve in an error response;
      #   (the Content-Length header, if any, is removed)
      def error_response err, headers={}
        headers.merge!({
            'Content-Type'     => "application/json",
            'X-Error-Message' => err.message,
            'X-Error-Detail'  => err.description,
          })
        headers.delete('Content-Length')
        if (err.description && (err.message != err.description))
          message  = "#{err.message}: #{err.description}"
        else
          message = err.message
        end
        body    = {
          "error"   => err.class.to_s.gsub(/.*::/,""),
          "message" => message,
          "status"  => err.status_code
        }
        [err.status_code, headers, body.to_json]
      end

      # @param status_code [Integer] HTTP status code for this error.
      # @param msg [String] message to inject into the response body.
      # @param headers [Hash] Response headers to preserve in an error response;
      #   (the Content-Length header, if any, is removed)
      def validation_error(status_code, msg, headers={})
        error_response(Goliath::Validation::Error.new(status_code, msg), headers)
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
      def safely(env, headers={})
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
require 'multi_json'

module Goliath
  module Rack
    module Formatters
      # A JSON formatter. Uses MultiJson so you can use the JSON
      # encoder that is right for your project.
      #
      # @example
      #   use Goliath::Rack::Formatters::JSON
      class JSON
        include AsyncMiddleware

        def post_process(env, status, headers, body)
          if self.class.applies_format?(headers)
            body = self.class.format(body)
          end
          [status, headers, body]
        end

        def json_response?(headers)
          p '*******************************************************'
          p [__FILE__, headers]
          self.class.applies_format?(headers)
        end

        def self.format(body)
          [MultiJson.encode(body)]
        end

        def self.applies_format?(headers)
          headers['Content-Type'] =~ %r{^application/(json|javascript)}
        end

      end
    end
  end
end
