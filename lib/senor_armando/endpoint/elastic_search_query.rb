Settings.define :elastic_search_host, :type => String,  :default => "localhost", :description => "Hostname of ElasticSearch HTTP interface (default localhost)"
Settings.define :elastic_search_port, :type => Integer, :default => 9200,        :description => "Port number for ElasticSearch HTTP interface (default 9200)"

module SenorArmando
  module Endpoint
    class ElasticSearchQuery < Goliath::API
      use Goliath::Rack::Params

      def es_server

      end

      def response(env)




      end
    end
  end
end
