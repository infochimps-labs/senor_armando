require 'spec_helper'
require Goliath.root_path('bin/armando_proxy')

describe ArmandoProxy do
  include SenorArmando::Spec::HeHelpMeTest

  let(:api_options){ { :config => config_file } }

  let(:run_server) do
    Proc.new do
      s = server(SenorArmando::Endpoint::Echo, 9009)
      Settings[:forwarder] = 'http://localhost:9009'
    end
  end

  it 'responds to requests by forwarding to a given responder' do
    get_api_request(ArmandoProxy) do |c|
      should_have_response(c,["Hello from Responder\n", 200])
    end
  end

  it 'responds to requests' do
    get_api_request(ArmandoProxy) do |c|
      should_have_ok_response(c)
    end
  end

  it 'forwards to our API server' do
    get_api_request(ArmandoProxy) do |c|
      should_have_ok_response(c)
      c.response.should == "Hello from Responder\n"
    end
  end

  context 'HTTP header handling' do
    it 'transforms back properly' do
      hl = ArmandoProxy.new
      hl.to_http_header('X_ECHO_SPECIAL').should == 'X-Echo-Special'
      hl.to_http_header('CONTENT_TYPE').should == 'Content-Type'
    end
  end

  context 'query parameters' do
    it 'forwards the query parameters' do
      get_api_request(ArmandoProxy, {:first => :foo, :second => :bar, :third => :baz}) do |c|
        should_have_ok_response(c)
        c.response_header['X_ECHO_PARAMS'].should =~ /"first":"foo"/
        c.response_header['X_ECHO_PARAMS'].should =~ /"second":"bar"/
      end
    end
  end

  context 'request path' do
    it 'forwards the request path' do
      get_api_request(ArmandoProxy, {}, {:path => '/my/request/path'}) do |c|
        should_have_ok_response(c)
        c.response_header['X_ECHO_PATH'].should == '/my/request/path'
      end
    end
  end

  context 'headers' do
    it 'forwards the headers' do
      get_api_request(ArmandoProxy, {}, {:head => {:first => :foo, :second => :bar}}) do |c|
        should_have_ok_response(c)
        c.response_header['X_ECHO_HEADERS'].should =~ /"First":"foo"/
        c.response_header['X_ECHO_HEADERS'].should =~ /"Second":"bar"/
      end
    end
  end

  context 'request method' do
    it 'forwards GET requests' do
      get_api_request(ArmandoProxy) do |c|
        should_have_ok_response(c)
        c.response_header['X_ECHO_METHOD'].should == 'GET'
      end
    end

    it 'forwards POST requests' do
      with_api_and_server(ArmandoProxy) do
        post_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'POST'
        end
      end
    end

    it 'forwards HEAD requests' do
      with_api_and_server(ArmandoProxy) do
        head_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'HEAD'
        end
      end
    end
  end

end
