require 'spec_helper'

require 'senor_armando/rack/force_timeout'

class TestForceTimeoutEndpoint < Goliath::API
  use Goliath::Rack::Params                     # parse & merge query and body parameters
  use SenorArmando::Rack::ExceptionHandler      # catch errors and present as non-200 responses
  use SenorArmando::Rack::ForceTimeout          # **testing this one**
  use SenorArmando::Rack::FaultInjection        # simulate a long-running result or failure in middleware

  def response(env)
    if env.params['raise_endpoint_error'].present?
      raise Goliath::Validation::DatabaseOnFireError
      [200, {}, "Hello from Responder\n"]
    end
  end
end


describe ForceTimeout do
  include SenorArmando::Spec::HeHelpMeTest
  let(:api_options){ { :config => config_file } }

  context 'no errors, endpoint is fast, middleware is fast' do
    before do
      Settings.force_timeout = 100
    end

    it 'Does nothing if I request no error' do
      get_api_request(ArmandoRaisesHell) do |c|
        should_have_ok_response(c)
      end
    end

    it 'Does nothing if I disallow errors' do
      Settings.fault_injection_errors = false
      get_api_request(ArmandoRaisesHell, :err_code => "404") do |c|
        should_have_ok_response(c)
      end
    end

    it 'Raises when given error codes' do
      get_api_request(ArmandoRaisesHell, :err_code => "404") do |c|
        should_have_response(c, ['{"error":"NotFoundError","message":"Not Found","status":"404"}', 404])
      end
      get_api_request(ArmandoRaisesHell, :err_code => "409") do |c|
        should_have_response(c, ['{"error":"ConflictError","message":"Conflict","status":"409"}', 409])
      end
      get_api_request(ArmandoRaisesHell, :err_code => "501") do |c|
        should_have_response(c, ['{"error":"NotImplementedError","message":"Not Implemented","status":"501"}', 501])
      end
    end

    it 'Raises when given error types' do
      get_api_request(ArmandoRaisesHell, :err_type => "PreconditionFailedError") do |c|
        should_have_response(c, ['{"error":"PreconditionFailedError","message":"Precondition Failed","status":"412"}', 412])
      end
      get_api_request(ArmandoRaisesHell, :err_type => "GatewayTimeoutError") do |c|
        should_have_response(c, ['{"error":"GatewayTimeoutError","message":"Gateway Time-out","status":"504"}', 504])
      end
    end

    it 'Raises when given derived error type' do
      get_api_request(ArmandoRaisesHell, :err_type => "ApiCallNotFoundError") do |c|
        should_have_response(c, ['{"error":"ApiCallNotFoundError","message":"No endpoint listening at that path. See listing at http://infochimps.com/api (Not Found)","status":"404"}', 404])
      end
    end

    it 'Does nothing if I request no error' do
      get_api_request(ArmandoRaisesHell) do |c|
        should_have_ok_response(c)
      end
    end

    it 'Raises BadRequestError if the type is bad' do
      get_api_request(ArmandoRaisesHell, :err_type => "YourMom") do |c|
         should_have_response(c, ['{"error":"BadRequestError","message":"Bad Request (You asked me to raise an error I cannot understand)","status":"400"}', 400])
      end
    end
    it 'Raises BadRequestError if the code is not 4xx or 5xx' do
      get_api_request(ArmandoRaisesHell, :err_code => 200) do |c|
         should_have_response(c, ['{"error":"BadRequestError","message":"Bad Request (You asked me to raise an error I cannot understand)","status":"400"}', 400])
      end
      get_api_request(ArmandoRaisesHell, :err_code => 600) do |c|
         should_have_response(c, ['{"error":"BadRequestError","message":"Bad Request (You asked me to raise an error I cannot understand)","status":"400"}', 400])
      end
    end
  end

  context 'requesting a delay' do
    before do
      Settings.fault_injection_sleepiness = true
      Settings.fault_injection_max_delay  = 250
      @start_time = Time.now
    end

    it 'does nothing if I request no delay' do
      get_api_request(ArmandoRaisesHell) do |c|
        should_have_ok_response(c)
        (Time.now - @start_time).should be_within(0.01).of(0)
      end
    end

    it 'delays by the requested amount' do
      get_api_request(ArmandoRaisesHell, :delay => 200) do |c|
        should_have_ok_response(c)
        (Time.now - @start_time).should be_within(0.01).of(0.2)
      end
    end

    it 'does not delay by more than Settings.fault_injection_max_delay' do
      Settings.fault_injection_max_delay = 150
      get_api_request(ArmandoRaisesHell, :delay => 200) do |c|
        should_have_response(c, ['{"error":"BadRequestError","message":"Bad Request (Requested delay 200 > max delay 150)","status":"400"}', 400])
        (Time.now - @start_time).should be_within(0.01).of(0)
      end
    end
  end
end

