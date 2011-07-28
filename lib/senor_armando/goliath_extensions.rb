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

    module AsyncMiddleware
      include ComponentName
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

  end
end
