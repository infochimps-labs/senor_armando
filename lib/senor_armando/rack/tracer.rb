Settings.define :tracer_name, :description => 'Name for header field', :finally => lambda{ Settings.tracer_name ||= "X-#{Settings.app_name}-Tracer" }

module Goliath
  module Rack

    class Tracer
      def initialize(app, header_name=nil)
        super(app)
        @header_name = header_name || Settings.tracer_name
      end
    end

  end
end
