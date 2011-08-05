#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '../lib/boot')

Settings[:forwarder] = 'http://localhost:9000'

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

  def dest_url_and_params(env)
    dest_url, dest_params = super(env)

    dest_params[:head].delete('Accept-Encoding') 

    p [__FILE__, dest_url, dest_params]
    [dest_url, dest_params]
  end
end
