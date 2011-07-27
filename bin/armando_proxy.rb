#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '../lib/boot')

# Usage:
#   ruby -r ./lib/boot.rb ./bin/armando_proxy.rb -sv -p 9001
#
#   curl -vv 'http://127.0.0.1:9001/unicodesnowmanforyou.com/'
#
# Takes all requests and forwards them to another server using EM-HTTP-Request.
# See http://everburning.com/news/stage-left-enter-goliath for more details --
#
class ArmandoProxy < SenorArmando::Endpoint::Proxy
  use Goliath::Rack::Heartbeat             # respond to /status with 200, OK (monitoring, etc)
  use Goliath::Rack::Tracer                # log trace statistics
  use Goliath::Rack::Params                # parse & merge query and body parameters
  use SenorArmando::Rack::ExceptionHandler # catch errors and present as non-200 responses
end
