module Rack
  #
  # This supports JSONP requests if there is a 'callback' parameter
  #
  # Usage:
  #   use Rack::Jsonp
  #
  class JsonpWrapper
    def initialize(app)
      @app = app
    end

    # Callbacks may only contain characters 0-9a-zA-Z_[]. and must start with a letter
    # Some other APIs also allow (),-+=/|\~?!#$^*: '" but not us
    VALID_CALLBACK_RE = /\A[a-zA-Z][\w\[\]\.]*\z/

    #
    # JSON-p callbacks
    #
    # If the callback parameter is present, wraps your response in a callback
    # method of your choice.  For example, if the non-callback URL returned a
    # response body of
    #
    #    {"what":"up"}
    #
    # appending &callback=cbFunc to the URL gives a response body of
    #
    #    cbFunc({"what":"up"})
    #
    # Callbacks may only contain characters 0-9a-zA-Z_[]. and must start with a
    # letter -- it must match /\A[a-zA-Z][\w\[\]\.]*\z/
    #
    # Requesting a callback on any call in the javascript/json family:
    #
    # * forces content type 'application/javascript', disregarding preferred mime type.
    # * forces a response code of 200. The former response code will be stored
    #   in the 'X-Response-Code' header.
    # * Sets the Access-Control-Allow-Origin header to '*' (allows all); see
    #   https://developer.mozilla.org/En/Server-Side_Access_Control
    #
    #
    def call(env)
      request = Rack::Request.new(env)
      status, headers, body = @app.call(env)
      callback = request.params["_callback"].to_s.strip

      if jsonp?(callback, headers['Content-Type'])
        body   = json_to_json_p(callback, body)
        headers.merge!({
            'Content-Type'    => 'application/javascript',
            'X-Response-Code' => status.to_s,
            'Content-Length'  => body.to_ary.inject(0){|len, part| len + part.bytesize }.to_s
          })
        status = 200
      end
      [status, headers, body]
    end

    def json_to_json_p callback, body
      body = [body] if body.respond_to?(:to_str)
      body = body.to_ary.join()
      [ "#{callback}(#{body.to_s.chomp})\n" ]
    end

    def jsonp? callback, media
      callback.present? &&
        (callback =~ VALID_CALLBACK_RE) &&
        (media    =~ %r{^(application|text)/(x-)?(javascript|json|json-p)})
    end
  end
end

