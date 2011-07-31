require 'goliath'

require 'gorillib'
require 'configliere'
require 'yajl/json_gem'
require 'gorillib/string/inflections'

require 'senor_armando/error'
require 'senor_armando/goliath_extensions'

module SenorArmando
  module Endpoint
    autoload :Proxy,        'senor_armando/endpoint/proxy'
    autoload :Echo,         'senor_armando/endpoint/echo'
  end

  module Rack
  end
end

