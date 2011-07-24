#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '../lib/boot')

require 'goliath/endpoint/echo'

# Usage:
#   ruby -r ./lib/boot.rb ./bin/goliath_echo.rb -sv -p 9002
#
#   curl -vv 'http://127.0.0.1:9002/this/that?the=other#yup'
#
# Summarizes the request back into the response header fields
#
class GoliathEcho < Goliath::Endpoint::Echo
  use Goliath::Rack::Heartbeat                  # respond to /status with 200, OK (monitoring, etc)
  use Goliath::Rack::Tracer, 'X-Tracer'         # log trace statistics
  use Goliath::Rack::Params                     # parse & merge query and body parameters
  use Goliath::Rack::ExceptionHandler           # catch errors and present as non-200 responses
end
