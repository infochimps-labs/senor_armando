require File.expand_path(File.join(File.dirname(__FILE__), 'senor_armando/use_gemfile_jail'))
$LOAD_PATH.unshift(Settings.root_path("lib")) unless $LOAD_PATH.include?(Settings.root_path("lib"))
require 'senor_armando'

Settings.define :app_name, :default => File.basename($0, '.rb'), :description => 'Name to key on for tracer stats, statsd metrics, etc.'
Settings.read(Settings.root_path('config/app.yaml'))
Settings.resolve!
