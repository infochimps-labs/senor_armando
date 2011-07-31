module SenorArmando
  module Endpoint
    class Echo < Goliath::API
      use Goliath::Rack::Params

      def on_headers(env, headers)
        env['client-headers'] = headers
      end

      def response(env)
        headers = {
          "X-Echo-Params"  => env.params.to_json,
          "X-Echo-Path"    => env[Goliath::Request::REQUEST_PATH],
          "X-Echo-Headers" => env['client-headers'].to_json,
          "X-Echo-Method"  => env[Goliath::Request::REQUEST_METHOD],
          "X-Echo-Special" => self.class.to_s
        }
        [200, headers, "Hello from Responder"]
      end
    end
  end
end

