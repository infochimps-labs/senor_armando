require 'goliath'

require 'senor_armando/errors'

module SenorArmando
  module Endpoint
    autoload :SenorArmando::Endpoint::Proxy,        'senor_armando/endpoint/proxy'
    autoload :SenorArmando::Endpoint::Echo,         'senor_armando/endpoint/echo'
  end

  module Rack
    # autoload :SenorArmando::Rack::EchoParams,       'senor_armando/rack/echo_params'
    autoload :SenorArmando::Rack::ExceptionHandler, 'senor_armando/rack/exception_handler'
    autoload :SenorArmando::Rack::EchoParams,       'senor_armando/rack/echo_params'
  end
end
