module Goliath
  ::Goliath::ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '../..')) unless defined?(::Goliath::ROOT_DIR)
  def self.root_path(*dirs)
    File.join(::Goliath::ROOT_DIR, *dirs)
  end
end
$LOAD_PATH.unshift(Goliath.root_path("lib")) unless $LOAD_PATH.include?(Goliath.root_path("lib"))


require File.expand_path(File.join(File.dirname(__FILE__), 'senor_armando/use_gemfile_jail'))
require 'em-http'
require 'em-synchrony/em-http'
#
require 'gorillib'
require 'yajl/json_gem'
require 'configliere'
#
require 'goliath/rack/exception_handler'
require 'goliath/rack/errors'
