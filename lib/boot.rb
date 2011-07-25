require File.expand_path(File.join(File.dirname(__FILE__), 'goliath_skeleton/use_gemfile_jail'))

$LOAD_PATH.unshift(Goliath.root_path("lib")) unless $LOAD_PATH.include?(Goliath.root_path("lib"))
$LOAD_PATH.unshift(Goliath.root_path("app")) unless $LOAD_PATH.include?(Goliath.root_path("app"))

require 'goliath'
require 'em-http'
require 'em-synchrony/em-http'
#
require 'gorillib'
require 'yajl/json_gem'
require 'configliere'
#
require 'goliath/rack/exception_handler'
require 'goliath/rack/errors'

Settings.define :app_name, :default => File.basename($0, '.rb'), :description => 'Name to key on for tracer stats, statsd metrics, etc.'
Settings.read(Goliath.root_path('config/app.yaml'))
Settings.resolve!
