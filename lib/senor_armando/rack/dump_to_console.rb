require 'awesome_print'

module SenorArmando
  module Rack

    #
    # Provides Cross-Origin Resource Sharing headers, a superior alternative to
    # JSON-p responses.
    #
    # This implementation is **entirely promiscuous**: it says "yep, that is
    # allowed" to _any_ request. The more circumspect user should investigate
    # https://github.com/cyu/rack-cors/
    #
    # @example
    #   # A request with method OPTIONS and Access-Control-Request-Headers set
    #   # to 'Content-Type,X-Zibit' would receive headers
    #   {
    #     'Access-Control-Allow-Origin'   => '*',
    #     'Access-Control-Allow-Methods'  => 'POST, GET, OPTIONS',
    #     'Access-Control-Max-Age'        => '172800',
    #     'Access-Control-Expose-Headers' => 'X-Error-Message,X-Error-Detail,X-RateLimit-Requests,X-RateLimit-MaxRequests',
    #     'Access-Control-Allow-Headers'  => 'Content-Type,X-Zibit'
    #   }
    #
    #
    class DumpToConsole
      include Goliath::Rack::AsyncMiddleware

      def self.dump_to_console(env, title, *contents)
        env.logger.debug("************* #{title}")
        contents.each do |content|
          if content.is_a?(String) && content.length > 1000
            content = content[0..1000]
          end
          ap(content)
        end
      end

      def call(env, *args)
        $stderr.puts "\n\n"
        env.logger.debug("-"*70)
        env.logger.debug("************* request #{Time.now}:")
        self.class.dump_to_console(env, 'request headers', env['client-headers']) if  env['client-headers'].present?
        super(env)
      end

      def post_process(env, status, headers, body)
        self.class.dump_to_console(env, 'body', unwind_body(body))
        self.class.dump_to_console(env, 'status', status)
        self.class.dump_to_console(env, 'headers', headers)
        [status, headers, body]
      end
    end

  end
end
