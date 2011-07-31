require 'spec_helper'

describe Goliath::Rack::Tracer do
  include SenorArmando::Spec::HeHelpMeTest
  let(:api_options){ { :config => config_file } }

  context 'naming the tracer ourselves' do
    before do
      Settings.app_name = 'TestEchoEndpoint'
      TestEchoEndpoint.use(Goliath::Rack::Tracer, 'bob')
    end

    it 'injects a trace param on a 200 (via async callback)' do
      with_api(TestEchoEndpoint) do
        get_api_request({:echo => 'test'}) do |c|
          c.response_header['X_TEST_ECHO_ENDPOINT_BOB'].should =~ /trace\.start: [\d\.]+, total: [\d\.]+/
        end
      end
    end

    it 'injects a trace param on a 400 (direct callback)' do
      with_api(TestEchoEndpoint) do
        get_api_request({}) do |c|
          c.response_header['X_TEST_ECHO_ENDPOINT_BOB'].should =~ /trace\.start: [\d\.]+, total: [\d\.]+/
        end
      end
    end
  end


  context 'without tracer ourselves, it uses its class' do
    before do
      Settings.app_name = 'TestEchoEndpoint'
      TestEchoEndpoint.use(Goliath::Rack::Tracer)
    end

    it 'injects a trace param on a 200 (via async callback)' do
      with_api(TestEchoEndpoint) do
        get_api_request({:echo => 'test'}) do |c|
          c.response_header['X_TEST_ECHO_ENDPOINT_TRACER'].should =~ /trace\.start: [\d\.]+, total: [\d\.]+/
        end
      end
    end

    it 'injects a trace param on a 400 (direct callback)' do
      with_api(TestEchoEndpoint) do
        get_api_request({}) do |c|
          c.response_header['X_TEST_ECHO_ENDPOINT_TRACER'].should =~ /trace\.start: [\d\.]+, total: [\d\.]+/
        end
      end
    end
  end

end
