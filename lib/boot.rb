require File.expand_path(File.join(File.dirname(__FILE__), 'use_gemfile_jail'))
$LOAD_PATH.unshift(ENV.root_path("lib")) unless $LOAD_PATH.include?(ENV.root_path("lib"))
require 'senor_armando'

Settings.define :app_name, :default => File.basename($0, '.rb'), :description => 'Name to key on for tracer stats, statsd metrics, etc.'
Settings.read(ENV.root_path('config/app.yaml'))
Settings.resolve!
