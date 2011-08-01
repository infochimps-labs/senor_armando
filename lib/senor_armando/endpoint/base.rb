module SenorArmando
  module Endpoint
    class Base < Goliath::API
      def response(env)
        [200, { "X-Echo-Special" => self.class.to_s }, "Hello from Responder"]
      end
    end
  end
end
