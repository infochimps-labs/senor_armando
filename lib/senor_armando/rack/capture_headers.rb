module SenorArmando
  module Rack
    #
    # Adds an +on_headers+ method, which stashes the client headers in +env['client-headers']+
    #
    # If you have your own on_headers method, be sure to call super()
    #
    module CaptureHeaders

      # Capture the headers when they roll in
      def on_headers(env, headers)
        env['client-headers'] = headers
      end

    end
  end
end
