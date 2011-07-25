require 'goliath'

require 'gorillib'
require 'configliere'
require 'yajl/json_gem'

require 'senor_armando/error'
require 'senor_armando/rack/tracer'

module SenorArmando
  module Endpoint
    autoload :Proxy,        'senor_armando/endpoint/proxy'
    autoload :Echo,         'senor_armando/endpoint/echo'
  end

  module Rack
    # autoload :SenorArmando::Rack::EchoParams,       'senor_armando/rack/echo_params'
    autoload :ExceptionHandler, 'senor_armando/rack/exception_handler'
  end
end
