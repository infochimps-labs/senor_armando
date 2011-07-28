module SenorArmando
  module Spec
    module HeHelpMeTest
      include Goliath::TestHelper

      DEFAULT_ERRBACK = Proc.new{|c| fail "HTTP Request failed #{c.response}" }

      def config_file
        Settings.root_path('config', 'app.rb')
      end

      def get_api_request(klass, query={}, params={}, errback=DEFAULT_ERRBACK, &block)
        with_api_and_server(klass) do |api|
          params[:query] = query
          get_request(params, errback, &block)
        end
      end

      def with_api_and_server(klass)
        with_api(klass, api_options) do |api|
          run_server.call(api) if defined?(run_server)
          yield
        end
      end

      def should_have_response(c,r)
        [c.response, c.response_header.status].should == r
      end

      def should_have_ok_response(c)
        [c.response, c.response_header.status].should == ["Hello from Responder\n", 200]
      end

      class TestEchoEndpoint < SenorArmando::Endpoint::Echo
        use Goliath::Rack::Params                     # parse & merge query and body parameters
      end
      
    end
  end
end
