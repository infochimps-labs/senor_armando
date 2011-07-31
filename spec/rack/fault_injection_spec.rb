require 'spec_helper'
require ENV.root_path('bin/armando_raises_hell')
require ENV.root_path('bin/armando_proxy')

describe ArmandoRaisesHell do
  include SenorArmando::Spec::HeHelpMeTest

  let(:api_options){ { :config => config_file } }

  context 'requesting an error' do
    before do
      Settings.fault_injection_errors = true
    end

    it 'Does nothing if I request no error' do
      with_api(ArmandoRaisesHell) do
        get_api_request() do |c|
          should_have_ok_response(c)
        end
      end
    end

    it 'Does nothing if I disallow errors' do
      Settings.fault_injection_errors = false
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_code => "404") do |c|
          should_have_ok_response(c)
        end
      end
    end

    it 'Raises when given error codes' do
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_code => "404") do |c|
          should_have_response(c, ['{"error":"NotFoundError","message":"Not Found","status":"404"}', 404])
        end
      end
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_code => "409") do |c|
          should_have_response(c, ['{"error":"ConflictError","message":"Conflict","status":"409"}', 409])
        end
      end
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_code => "501") do |c|
          should_have_response(c, ['{"error":"NotImplementedError","message":"Not Implemented","status":"501"}', 501])
        end
      end
    end

    it 'Raises when given error types' do
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_type => "PreconditionFailedError") do |c|
          should_have_response(c, ['{"error":"PreconditionFailedError","message":"Precondition Failed","status":"412"}', 412])
        end
      end
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_type => "GatewayTimeoutError") do |c|
          should_have_response(c, ['{"error":"GatewayTimeoutError","message":"Gateway Time-out","status":"504"}', 504])
        end
      end
    end

    it 'Raises when given derived error type' do
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_type => "ApiCallNotFoundError") do |c|
          should_have_response(c, ['{"error":"ApiCallNotFoundError","message":"Not Found: No endpoint listening at that path. See listing at http://infochimps.com/api","status":"404"}', 404])
        end
      end
    end

    it 'Does nothing if I request no error' do
      with_api(ArmandoRaisesHell) do
        get_api_request() do |c|
          should_have_ok_response(c)
        end
      end
    end

    it 'Raises BadRequestError if the type is bad' do
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_type => "YourMom") do |c|
          should_have_response(c, ['{"error":"BadRequestError","message":"You asked me to raise an error I cannot understand: Bad Request","status":"400"}', 400])
        end
      end
    end
    it 'Raises BadRequestError if the code is not 4xx or 5xx' do
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_code => 200) do |c|
          should_have_response(c, ['{"error":"BadRequestError","message":"You asked me to raise an error I cannot understand: Bad Request","status":"400"}', 400])
        end
      end
      with_api(ArmandoRaisesHell) do
        get_api_request(:err_code => 600) do |c|
          should_have_response(c, ['{"error":"BadRequestError","message":"You asked me to raise an error I cannot understand: Bad Request","status":"400"}', 400])
        end
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
      with_api(ArmandoRaisesHell) do
        get_api_request() do |c|
          should_have_ok_response(c)
          (Time.now - @start_time).should be_within(0.01).of(0)
        end
      end
    end

    it 'delays by the requested amount' do
      with_api(ArmandoRaisesHell) do
        get_api_request(:delay => 200) do |c|
          should_have_ok_response(c)
          (Time.now - @start_time).should be_within(0.01).of(0.2)
        end
      end
    end

    it 'does not delay by more than Settings.fault_injection_max_delay' do
      Settings.fault_injection_max_delay = 150
      with_api(ArmandoRaisesHell) do
        get_api_request(:delay => 200) do |c|
          should_have_response(c, ['{"error":"BadRequestError","message":"Requested delay 200 > max delay 150: Bad Request","status":"400"}', 400])
          (Time.now - @start_time).should be_within(0.01).of(0)
        end
      end
    end
  end
end

