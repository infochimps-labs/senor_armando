require 'postrank-uri'
Settings.define :forwarder, :required => true, :description => "Destination host to forward requests to"

#
# Takes all requests and forwards them to another server using EM-HTTP-Request.
#
# See http://everburning.com/news/stage-left-enter-goliath for more details --
#
module SenorArmando
  module Endpoint
    class Proxy < Goliath::API

      # Capture the headers when they roll in, to replay for the remote target
      def on_headers(env, headers)
        env['client-headers'] = headers
      end

      def dest_url_and_params(env)
        dest_params = {:head => env['client-headers'], :query => env.params}

        # Set the target host correctly
        dest_url = PostRank::URI.normalize("#{Settings[:forwarder]}#{env[Goliath::Request::REQUEST_PATH]}")

        env.logger.info ['proxy', dest_url].join("\t")
        [dest_url, dest_params]
      end

      # Pass the call request on to the target host
      def response(env)
        env.trace :response_beg

        dest_url, dest_params = dest_url_and_params(env)
        dest_params[:head]['Host'] = dest_url.host
        env.logger.debug( [dest_url, dest_params] )

        req = EM::HttpRequest.new(dest_url.to_s)
        resp =
          case(env[Goliath::Request::REQUEST_METHOD])
          when 'GET'  then req.get(dest_params)
          when 'POST' then req.post(dest_params.merge(:body => (env[Goliath::Request::RACK_INPUT].read || '')))
          when 'HEAD' then req.head(dest_params)
          else raise Goliath::Validation::BadRequestError.new("Uncool method #{env[Goliath::Request::REQUEST_METHOD]}")
          end

        env.trace :response_end
        [resp.response_header.status, response_header_hash(resp), resp.response]
      end

      # Need to convert from the CONTENT_TYPE we'll get back from the server
      # to the normal Content-Type header
      def response_header_hash(resp)
        hsh = {}
        resp.response_header.each_pair do |k, v|
          hsh[to_http_header(k)] = v
        end
        hsh
      end

      def to_http_header(k)
        k.downcase.split('_').map{|e| e.capitalize }.join('-')
      end
    end
  end
end
