#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '../lib/boot')

require 'goliath'
# require 'goliath/synchrony/response_receiver'
require 'goliath/rack/async_barrier'
require 'goliath/rack/barrier_middleware'
require 'em-synchrony/em-http'
require 'yajl/json_gem'

#
# Here's a way to make an asynchronous request in the middleware, and only
# proceed with the response when both the endpoint and our middleware's
# responses have completed.
#
# To run this, start the 'test_rig.rb' server on port 9002:
#
#   ./examples/test_rig.rb -sv -p 9002
#
# And then start this server on port 9000:
#
#   ./async_aroundware_demo.rb -sv -p 9000
#
# Now curl the async_aroundware_demo_multi:
#
#    $ time curl  'http://127.0.0.1:9000/?delay_1=1.0&delay_2=1.5'
#         { "results": {
#             "sleep_2": { "delay": 1.5, "actual": 1.5085558891296387 },
#             "sleep_1": { "delay": 1.0, "actual": 1.0098700523376465 }
#           } }
#
# The requests are run concurrently:
#
#   $ ./examples/async_aroundware_demo.rb -sv -p 9000 -e prod &
#   [68463:INFO] 2011-05-03 23:13:03 :: Starting server on 0.0.0.0:9000 in production mode. Watch out for stones.
#   $ ab -n10 -c10 'http://127.0.0.1:9000/?delay_1=1.5&delay_2=2.0'
#   Connection Times (ms)
#                 min  mean[+/-sd] median   max
#   Connect:        0    0   0.1      0       0
#   Processing:  2027 2111  61.6   2112    2204
#   Waiting:     2027 2111  61.5   2112    2204
#   Total:       2027 2112  61.5   2113    2204
#
#

BASE_URL     = 'http://localhost:9002/'

class VariableDelayBarrier
  include Goliath::Rack::AsyncBarrier
  attr_accessor :sleep_1

  def pre_process
    # Request with delay_1 and drop_1 -- note: 'aget', because we want execution to continue
    req = EM::HttpRequest.new(BASE_URL).aget(:query => { :delay => env.params['delay_1'], :drop => env.params['drop_1'] })
    enqueue :sleep_1, req
    Goliath::Connection::AsyncResponse
  end

  # unify the results with the results of the API call
  def post_process
    successes.delete(:downstream_resp) ; failures.delete(:downstream_resp)
    successes.each{|name, resp|  body[:results][name] = JSON.parse(resp.response) }
    failures.each{|name, err|    body[:errors][name]  = err.error }
    #
    [status, headers, JSON.generate(body)]
  end
end

class BarrierMiddlewareDemo < Goliath::API
  use Goliath::Rack::Params
  use Goliath::Rack::Validation::NumericRange, {:key => 'delay_1', :default => 1.0, :max => 5.0, :min => 0.0, :as => Float}
  use Goliath::Rack::Validation::NumericRange, {:key => 'delay_2', :default => 0.5, :max => 5.0, :min => 0.0, :as => Float}
  #
  use Goliath::Rack::BarrierMiddleware, VariableDelayBarrier

  def response(env)
    # Request with delay_2 and drop_2 -- note: 'get', because we want execution to proceed linearly
    resp = EM::HttpRequest.new(BASE_URL).get(:query => { :delay => env.params['delay_2'], :drop => env.params['drop_2'] })

    body = { :results => {}, :errors => {} }

    if resp.response_header.status.to_i != 0
      body[:results][:sleep_2] = JSON.parse(resp.response)
    else
      body[:errors ][:sleep_2] = resp.error
    end

    [200, { }, body]
  end
end
