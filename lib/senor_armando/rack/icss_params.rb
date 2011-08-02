require 'gorillib/hashlike'
require 'gorillib/hashlike/deep_hash'
require 'gorillib/receiver'
require 'gorillib/receiver_model'
require 'gorillib/metaprogramming/class_attribute'

module Cornelius
  module Geolocator
    class Base
      include Gorillib::ReceiverModel
    end

    class PointRadius < Base
      rcvr_accessor :latitude, Float
      rcvr_accessor :longitude, Float
      rcvr_accessor :radius, Float
    end

    class PointZoom < Base
      rcvr_accessor :latitude, Float
      rcvr_accessor :longitude, Float
      rcvr_accessor :zoom_level, Integer
    end

    class BoundingBox < Base
      rcvr_accessor :x_0, Float
      rcvr_accessor :y_0, Float
      rcvr_accessor :x_1, Float
      rcvr_accessor :y_1, Float
    end

    class TileId < Base
      rcvr_accessor :tile_x, Integer
      rcvr_accessor :tile_y, Integer
      rcvr_accessor :zoom_level, Integer
    end

  end

  module Filter
    class Base
      include Gorillib::ReceiverModel
    end


  end

  class RequestModel
    include Gorillib::ReceiverModel
    rcvr_accessor :g_pr,   Cornelius::Geolocator::PointRadius
    rcvr_accessor :g_xyz,  Cornelius::Geolocator::PointZoom
    rcvr_accessor :g_bbox, Cornelius::Geolocator::BoundingBox
    rcvr_accessor :g_tile, Cornelius::Geolocator::TileId
  end
end

module SenorArmando
  module Rack

    # Prepare an Icss model instance from the request path and parsed params
    #
    # @note
    #   you must `use Goliath::Rack::Params` before this in your endpoint
    #
    # @example
    #   use SenorArmando::Rack::Introspect
    #
    class ParamsModel

      def initialize(app)
        @app = app
      end

      class DeepHash < Hash
        include Gorillib::Hashlike::DeepHash
      end

      #
      # @example
      #   env.params     # {'a.b.c' =>        {'d' => 3, 'f.g'    => 7 },    'p' => 9 }
      #   nested_params  # {:a => {:b=> {:c=> {:d   =>3, :f=>{ :g =>7  }}}}, :p  => 9 }
      #
      def nested_params(env)
        hsh = DeepHash.new()
        hsh.deep_merge!(env.params)
        hsh
      end

      def call(env)
        Goliath::Rack::Validator.safely(env) do
          np = env['nested_params'] = nested_params(env)
          p np
          obj = Cornelius::RequestModel.receive(np)
          p obj
          # @app.call(env)
          [200, {}, obj.to_hash.to_json]
        end
      end
    end
  end
end
