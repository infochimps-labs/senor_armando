module SenorArmando
  module Spec
    module HeHelpMeTest
      include Goliath::TestHelper

      DEFAULT_ERRBACK = Proc.new{|c| fail "HTTP Request failed #{c.response}" }

      def config_file
        ENV.root_path('config', 'app.rb')
      end

      def with_api(klass, opts=nil, &block)
        super(klass, (opts||api_options), &block)
      end

      def with_api_and_server(klass, opts=nil)
        with_api(klass) do |api|
          run_server.call(api) if defined?(run_server)
          yield
        end
      end

      def get_api_request(query={}, params={}, errback=DEFAULT_ERRBACK, &block)
        params[:query] = query
        get_request(params, errback, &block)
      end

      def should_have_response(c,r)
        [c.response, c.response_header.status].should == r
      end

      def should_have_ok_response(c)
        [c.response, c.response_header.status].should == ["Hello from Responder", 200]
      end

      class TestEchoEndpoint < SenorArmando::Endpoint::Echo
        use Goliath::Rack::Params                     # parse & merge query and body parameters
      end

    end
  end
end
