# TODO: factor out the mongo and apey_eye specific code
require 'spec_helper'
require Goliath.root_path('app/passthru_proxy')
require 'goliath/endpoint/echo'

describe PassthruProxy do
  include GoliathSkeleton::TestHelper

  let(:api_options){ { :config => config_file } }

  it 'responds to requests by forwarding to a given responder' do
    with_echo_target(PassthruProxy, api_options) do
      get_api_request() do |c|
        should_have_response(c,["Hello from Responder\n", 200])
      end
    end
  end

  it 'responds to requests' do
    with_echo_target(PassthruProxy, api_options) do
      get_api_request() do |c|
        should_have_ok_response(c)
      end
    end
  end

  it 'forwards to our API server' do
    with_echo_target(PassthruProxy, api_options) do
      get_api_request() do |c|
        should_have_ok_response(c)
        c.response.should == "Hello from Responder\n"
      end
    end
  end

  context 'HTTP header handling' do
    it 'transforms back properly' do
      hl = PassthruProxy.new
      hl.to_http_header('X_ECHO_SPECIAL').should == 'X-Echo-Special'
      hl.to_http_header('CONTENT_TYPE').should == 'Content-Type'
    end
  end

  context 'query parameters' do
    it 'forwards the query parameters' do
      with_echo_target(PassthruProxy, api_options) do
        get_api_request({:first => :foo, :second => :bar, :third => :baz}) do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_PARAMS'].should =~ /"first":"foo"/
          c.response_header['X_ECHO_PARAMS'].should =~ /"second":"bar"/
        end
      end
    end
  end

  context 'request path' do
    it 'forwards the request path' do
      with_echo_target(PassthruProxy, api_options) do
        get_api_request({}, {:path => '/my/request/path'}) do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_PATH'].should == '/my/request/path'
        end
      end
    end
  end

  context 'headers' do
    it 'forwards the headers' do
      with_echo_target(PassthruProxy, api_options) do
        get_api_request({}, {:head => {:first => :foo, :second => :bar}}) do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_HEADERS'].should =~ /"First":"foo"/
          c.response_header['X_ECHO_HEADERS'].should =~ /"Second":"bar"/
        end
      end
    end
  end

  context 'request method' do
    it 'forwards GET requests' do
      with_echo_target(PassthruProxy, api_options) do
        get_api_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'GET'
        end
      end
    end

    it 'forwards POST requests' do
      with_echo_target(PassthruProxy, api_options) do
        post_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'POST'
        end
      end
    end

    it 'forwards POST requests' do
      with_echo_target(PassthruProxy, api_options) do
        head_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'HEAD'
        end
      end
    end
  end

end
