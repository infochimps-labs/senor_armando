require 'spork'

Spork.prefork do
  # This code is run only once when the spork server is started

  ENV["RACK_ENV"] ||= 'test'
  RACK_ENV = ENV["RACK_ENV"] unless defined?(RACK_ENV)

  require File.join(File.dirname(__FILE__), '../lib/boot')
  require 'rspec'
  require 'goliath/test_helper'

  # Requires custom matchers & macros, etc from files in ./support/ & subdirs
  Dir[Goliath.root_path("spec/support/**/*.rb")].each {|f| require f}

  # Configure rspec
  RSpec.configure do |config|
    config.include Goliath::TestHelper, :example_group => { :file_path => /spec/ }
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
end
