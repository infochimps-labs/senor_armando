module GoliathSkeleton
  module TestHelper
    include Goliath::TestHelper

    DEFAULT_ERRBACK = Proc.new{|c| fail "HTTP Request failed #{c.response}" }

    def config_file
      Goliath.root_path('config', 'app.rb')
    end

    def get_api_request query={}, params={}, errback=DEFAULT_ERRBACK, &block
      params[:query] = query
      get_request(params, errback, &block)
    end

    def should_have_response(c,r)
      [c.response, c.response_header.status].should == r
    end

    def should_have_ok_response(c)
      [c.response, c.response_header.status].should == ["Hello from Responder\n", 200]
    end

    def with_echo_target api, options
      with_api(api, options) do |api|
        s = server(Goliath::Endpoint::Echo, 9009)
        Settings[:forwarder] = 'http://localhost:9009'
        yield
      end
    end

  end
end
