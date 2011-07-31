require 'goliath'

require 'gorillib'
require 'configliere'
require 'yajl/json_gem'
require 'gorillib/string/inflections'

require 'senor_armando/error'
require 'senor_armando/goliath_extensions'

module SenorArmando
  def self.path_to(*args)
    File.expand_path(File.join(File.dirname(__FILE__), '..', *args))
  end

  module Endpoint
    autoload :Proxy,        'senor_armando/endpoint/proxy'
    autoload :Echo,         'senor_armando/endpoint/echo'
  end

  module Rack
  end
end
