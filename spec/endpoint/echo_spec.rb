require 'spec_helper'
require ENV.root_path('bin/armando_echo')

describe ArmandoEcho do
  include SenorArmando::Spec::HeHelpMeTest

  let(:api_options){ { :config => config_file } }

  it 'responds to requests by echoing a happy message' do
    with_api(ArmandoEcho) do
      get_api_request() do |c|
        should_have_ok_response(c)
      end
    end
  end

  context 'query parameters' do
    it 'echos the query parameters in "X-Echo-Params"' do
      with_api(ArmandoEcho) do
        get_api_request({:first => :foo, :second => :bar, :third => :baz}) do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_PARAMS'].should =~ /"first":"foo"/
          c.response_header['X_ECHO_PARAMS'].should =~ /"second":"bar"/
        end
      end
    end
  end

  context 'request path' do
    it 'echos the request path in X-Echo-Path' do
      with_api(ArmandoEcho) do
        get_api_request({}, {:path => '/my/request/path'}) do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_PATH'].should == '/my/request/path'
        end
      end
    end
  end

  context 'headers' do
    it 'echos the headers in X-Echo-Headers' do
      with_api(ArmandoEcho) do
        get_api_request({}, {:head => {:first => :foo, :second => :bar}}) do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_HEADERS'].should =~ /"First":"foo"/
          c.response_header['X_ECHO_HEADERS'].should =~ /"Second":"bar"/
        end
      end
    end
  end

  context 'request method' do
    it 'echos GET requests, with method in X-Echo-Method' do
      with_api(ArmandoEcho) do
        get_api_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'GET'
        end
      end
    end

    it 'echos POST requests, with method in X-Echo-Method' do
      with_api(ArmandoEcho) do
        post_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'POST'
        end
      end
    end

    it 'echos HEAD requests, with method in X-Echo-Method' do
      with_api(ArmandoEcho) do
        head_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'HEAD'
        end
      end
    end
  end
end
