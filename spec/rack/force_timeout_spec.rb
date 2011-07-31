require 'spec_helper'

require 'senor_armando/rack/force_timeout'
require 'senor_armando/rack/fault_injection'

class TestForceTimeoutEndpoint < Goliath::API
  use Goliath::Rack::Params                     # parse & merge query and body parameters
  use SenorArmando::Rack::ForceTimeout          # **testing this one**
  use SenorArmando::Rack::FaultInjection        # simulate a long-running result or failure in middleware

  def response(env)
    if env.params['endpoint_raise_error'].present?
      raise Goliath::Validation::DatabaseOnFireError
    end
    if env.params['endpoint_delay'].present?
      p ['delay', env.params['endpoint_delay']]
      EM::Synchrony.sleep(  env.params['endpoint_delay'].to_f / 1000 )
    end
    [200, {}, "Hello from Responder"]
  end
end

describe SenorArmando::Rack::ForceTimeout do
  include SenorArmando::Spec::HeHelpMeTest
  let(:api_options){ { :config => config_file } }
  before do
    Settings.force_timeout = 100
    Settings.app_name = 'TestForceTimeoutEndpoint'
    @start_time = Time.now
  end

  context 'no errors' do

    context 'endpoint is fast, middleware is fast' do
      it 'succeeds' do
        with_api(TestForceTimeoutEndpoint) do
          get_api_request(:endpoint_delay => 20) do |c|
            should_have_ok_response(c)
          end
        end
      end
    end

    context 'endpoint is slow, middleware is fast' do
      it 'fails' do
        with_api(TestForceTimeoutEndpoint) do
          get_api_request(:endpoint_delay => 200) do |c|
            should_have_response(c, ['{"error":"RequestTimeoutError","message":"Request exceeded 100 ms: Request Time-out","status":"408"}', 408])
          end
        end
      end
    end

  end
end
