#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '../lib/boot')

require 'goliath/endpoint/proxy'

# Usage:
#
# Start the server:
#
#   ./app/passthru_proxy.rb -sv -p 9001 --config $PWD/config/app.rb
#
#   curl -vv 'http://127.0.0.1:9001/unicodesnowmanforyou.com/'
#
# Takes all requests and forwards them to another server using EM-HTTP-Request.
#
# See http://everburning.com/news/stage-left-enter-goliath for more details --
#
class PassthruProxy < Goliath::Endpoint::Proxy
  use Goliath::Rack::Heartbeat                                   # respond to /status with 200, OK (monitoring, etc)
  use Goliath::Rack::Tracer, 'X-Tracer'                          # log trace statistics
  use Goliath::Rack::Params                                      # parse & merge query and body parameters

  # use Goliath::Rack::StatsdLogger, Settings.statsd_logger_handle # send request logs to statsd
  # plugin Goliath::Plugin::StatsdPlugin                           # send internal stats to statsd

  # def dest_url_and_params(env)
  #   dest_params = {:head => env['client-headers'], :query => env.params}
  #
  #   # Pull the base URI out of the path info
  #   env['PATH_INFO'] =~ %r{\A/([\w\.\-]+)/(.*)\z}o or raise Goliath::Validation::BadRequestError.new("Cannot forward to [#{env['PATH_INFO']}]")
  #   dest_host, dest_path = [$1, $2]
  #
  #   # Set the target host correctly
  #   dest_params[:head]['Host'] = dest_host
  #   url = "http://#{dest_host}/#{dest_path}"
  #
  #   [dest_url, dest_params]
  # end

end
