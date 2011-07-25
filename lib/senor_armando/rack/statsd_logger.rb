Settings.define :statsd_name, :description => 'Name for statsd metrics', :finally => lambda{ Settings.statsd_name ||= Settings.app_name }

module Goliath
  module Rack
    class StatsdLogger
      include Goliath::Rack::AsyncMiddleware

      def initialize app, name=nil
        @name = name || Settings.statsd_name
        super(app)
      end

      def call(env)
        agent.count [@name, :req, route(env)] if agent
        super(env)
      end

      def post_process(env, status, headers, body)
        agent.timing([@name, :req_time, route(env)], (1000 * (Time.now.to_f - env[:start_time].to_f))) if agent
        agent.timing([@name, :req_time, status],     (1000 * (Time.now.to_f - env[:start_time].to_f))) if agent
        [status, headers, body]
      end

      def agent
        Goliath::Plugin::StatsdPlugin.agent
      end

      def route(env)
        path = env['PATH_INFO'].gsub(%r{^/}, '')
        return 'root' if path == ''
        path.gsub(%r{/}, '.')
      end
    end
  end
end
