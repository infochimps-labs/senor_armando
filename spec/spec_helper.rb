require 'spork'

Spork.prefork do
  # This code is run only once when the spork server is started

  ENV["RACK_ENV"] ||= 'test'
  RACK_ENV = ENV["RACK_ENV"] unless defined?(RACK_ENV)

  require File.expand_path(File.join(File.dirname(__FILE__), '../lib/boot'))
  Settings.define :app_name, :default => File.basename($0, '.rb'), :description => 'Name to key on for tracer stats, statsd metrics, etc.'

  require 'rspec'
  require 'goliath'
  require 'goliath/test_helper'
  require 'senor_armando'
  require 'senor_armando/spec/he_help_me_test'

  # Requires custom matchers & macros, etc from files in ./support/ & subdirs
  Dir[ENV.root_path("spec/support/**/*.rb")].each {|f| require f}

  # Configure rspec
  RSpec.configure do |config|
    config.include SenorArmando::Spec::HeHelpMeTest, :example_group => { :file_path => /spec/ }
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
end
