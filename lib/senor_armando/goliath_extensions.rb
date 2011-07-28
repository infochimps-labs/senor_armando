require 'gorillib/string/inflections'
module Goliath
  module Rack

    module AsyncMiddleware
      def header_slug(key)
        dasherized_name = app_name.underscore.split('_').map(&:capitalize).join('-')
        "X-#{dasherized_name}-#{key}".gsub(/[^\w\-]+/, '-')
      end

      def app_name
        Settings.app_name || Goliath::Application.app_class.to_s.demodulize
      end
    end

    # make Tracer respect the header name

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

  end
end
