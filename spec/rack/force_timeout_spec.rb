require 'spec_helper'

require 'senor_armando/rack/force_timeout'

class TestForceTimeoutEndpoint < Goliath::API
  use Goliath::Rack::Params                     # parse & merge query and body parameters
  use SenorArmando::Rack::ExceptionHandler      # catch errors and present as non-200 responses
  use SenorArmando::Rack::ForceTimeout          # **testing this one**
  # use SenorArmando::Rack::FaultInjection        # simulate a long-running result or failure in middleware

  def response(env)
    if env.params['raise_endpoint_error'].present?
      raise Goliath::Validation::DatabaseOnFireError
      [200, {}, "Hello from Responder\n"]
    end
  end
end

describe SenorArmando::Rack::ForceTimeout do
  include SenorArmando::Spec::HeHelpMeTest
  let(:api_options){ { :config => config_file } }
  before do
    Settings.force_timeout = 100
    Settings.app_name = 'TestForceTimeoutEndpoint'
  end

  context 'no errors, endpoint is fast, middleware is fast' do
    it 'succeeds' do
      get_api_request(ArmandoRaisesHell) do |c|
        should_have_ok_response(c)
      end
    end
  end

end

