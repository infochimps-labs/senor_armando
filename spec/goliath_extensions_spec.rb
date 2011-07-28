require 'spec_helper'

describe Goliath::Rack::Tracer do
  include SenorArmando::Spec::HeHelpMeTest
  let(:err){ Proc.new{ fail "API request failed" } }

  context 'naming the tracer ourselves' do
    before do
      Settings.app_name = 'TestEchoEndpoint'
      TestEchoEndpoint.use(Goliath::Rack::Tracer, 'bob')
    end

    it 'injects a trace param on a 200 (via async callback)' do
      with_api(TestEchoEndpoint) do
        get_request({:query => {:echo => 'test'}}, err) do |c|
          c.response_header['X_TEST_ECHO_ENDPOINT_BOB'].should =~ /trace\.start: [\d\.]+, total: [\d\.]+/
        end
      end
    end

    it 'injects a trace param on a 400 (direct callback)' do
      with_api(TestEchoEndpoint) do
        get_request({}, err) do |c|
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
        get_request({:query => {:echo => 'test'}}, err) do |c|
          c.response_header['X_TEST_ECHO_ENDPOINT_TRACER'].should =~ /trace\.start: [\d\.]+, total: [\d\.]+/
        end
      end
    end

    it 'injects a trace param on a 400 (direct callback)' do
      with_api(TestEchoEndpoint) do
        get_request({}, err) do |c|
          c.response_header['X_TEST_ECHO_ENDPOINT_TRACER'].should =~ /trace\.start: [\d\.]+, total: [\d\.]+/
        end
      end
    end
  end 

end
