require 'multi_json'

module SenorArmando
  module Formatters
    # A JSON formatter. Uses MultiJson so you can use the JSON
    # encoder that is right for your project.
    #
    # @example
    #   use Goliath::Rack::Formatters::JSON
    class JSON

      def self.applies_format?(headers)
        headers['Content-Type'] =~ %r{^application/(json|javascript)}
      end

      def self.format(body)
        [MultiJson.encode(body)]
      end

    end
  end
end
