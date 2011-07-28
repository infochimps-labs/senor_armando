# TODO: factor out the mongo and apey_eye specific code
require 'spec_helper'
require Goliath.root_path('bin/armando_echo')

describe ArmandoEcho do
  include SenorArmando::Spec::HeHelpMeTest

  let(:api_options){ { :config => config_file } }

  it 'responds to requests by echoing a happy message' do
    get_api_request(ArmandoEcho) do |c|
      should_have_ok_response(c)
    end
  end 

  context 'query parameters' do
    it 'echos the query parameters in "X-Echo-Params"' do
      get_api_request(ArmandoEcho, {:first => :foo, :second => :bar, :third => :baz}) do |c|
        should_have_ok_response(c)
        c.response_header['X_ECHO_PARAMS'].should =~ /"first":"foo"/
        c.response_header['X_ECHO_PARAMS'].should =~ /"second":"bar"/
      end
    end
  end

  context 'request path' do
    it 'echos the request path in X-Echo-Path' do
      get_api_request(ArmandoEcho, {}, {:path => '/my/request/path'}) do |c|
        should_have_ok_response(c)
        c.response_header['X_ECHO_PATH'].should == '/my/request/path'
      end
    end
  end

  context 'headers' do
    it 'echos the headers in X-Echo-Headers' do
      get_api_request(ArmandoEcho, {}, {:head => {:first => :foo, :second => :bar}}) do |c|
        should_have_ok_response(c)
        c.response_header['X_ECHO_HEADERS'].should =~ /"First":"foo"/
        c.response_header['X_ECHO_HEADERS'].should =~ /"Second":"bar"/
      end
    end
  end

  context 'request method' do
    it 'echos GET requests, with method in X-Echo-Method' do
      get_api_request(ArmandoEcho) do |c|
        should_have_ok_response(c)
        c.response_header['X_ECHO_METHOD'].should == 'GET'
      end
    end

    it 'echos POST requests, with method in X-Echo-Method' do
      with_api_and_server(ArmandoEcho) do
        post_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'POST'
        end
      end
    end

    it 'echos HEAD requests, with method in X-Echo-Method' do
      with_api_and_server(ArmandoEcho) do
        head_request() do |c|
          should_have_ok_response(c)
          c.response_header['X_ECHO_METHOD'].should == 'HEAD'
        end
      end
    end
  end

end
