#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '../lib/boot')

require 'goliath/endpoint/proxy'

# Usage:
#   ruby -r ./lib/boot.rb ./bin/goliath_repeater -sv -p 9001
#
#   curl -vv 'http://127.0.0.1:9001/unicodesnowmanforyou.com/'
#
# Takes all requests and forwards them to another server using EM-HTTP-Request.
# See http://everburning.com/news/stage-left-enter-goliath for more details --
#
class GoliathRepeater < Goliath::Endpoint::Proxy
  use Goliath::Rack::Heartbeat                  # respond to /status with 200, OK (monitoring, etc)
  use Goliath::Rack::Tracer, 'X-Tracer'         # log trace statistics
  use Goliath::Rack::Params                     # parse & merge query and body parameters
  use Goliath::Rack::ExceptionHandler           # catch errors and present as non-200 responses
end
