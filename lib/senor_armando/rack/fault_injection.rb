require 'gorillib/string/inflections'
require 'gorillib/string/constantize'
require 'gorillib/receiver'

Settings.define :fault_injection_errors,     :description => 'Allow requests to raise an error', :type => :boolean, :default => false
Settings.define :fault_injection_sleepiness, :description => 'Allow requests to inject a delay', :type => :boolean, :default => false
Settings.define :fault_injection_max_delay,  :description => 'Allow requests to inject a delay', :type => Integer,  :default => 2000

module SenorArmando
  module Rack
    class FaultInjection
      include Goliath::Rack::AsyncMiddleware

      def call(env)
        fault_injector = FaultInjector.receive(env.params, env)
        fault_injector.maybe_raise_error!
        fault_injector.maybe_sleep!
        super(env, fault_injector)
      end

      def post_process(env, status, headers, body)
        [status, headers, body]
      end

      class FaultInjector
        include Receiver
        attr_accessor :env
        rcvr_accessor :err_code, Integer, :doc => 'The http status code for the response. You may only specify err_code or err_type'
        rcvr_accessor :err_type, String,  :doc => 'The API error type to return. You may only specify err_code or err_type'
        rcvr_accessor :delay,    Integer, :doc => 'Artificially delay the response by this amount'

        def initialize env
          self.env = env
        end

        def maybe_raise_error! err_type, err_code
          return unless Settings.fault_injection_errors
          return unless err_type.present? || err_code.present?

          # get the error klass, probably
          if    err_type.present? then err_klass = "Goliath::Validation::#{err_type.camelize}".constantize rescue nil
          elsif err_code.present? then err_klass = Goliath::HTTP_ERRORS[err_code.to_i]
          else  return; end

          # If an error *was* requested but is bad, throw our error not theirs
          unless err_klass && (err_klass < Goliath::Validation::Error)
            raise Goliath::Validation::BadRequestError.new("You asked me to raise an error I cannot understand")
          end

          # OK throw error
          raise err_klass
        end

        def maybe_sleep!
          return unless Settings.fault_injection_sleepiness
          return unless delay && delay > 0
          if delay > Settings.fault_injection_max_delay then raise Goliath::Validation::BadRequestError, "Requested delay #{delay} > max delay #{Settings.fault_injection_max_delay}"; end
          EM::Synchrony.sleep(delay.to_f / 1000)
        end

      end
    end
  end
end
