require 'rack/mime'
require 'rack/respond_to'
require 'pathname'

module SenorArmando
  module Rack
    # The render middleware will set the Content-Type of the response
    # based on the provided HTTP_ACCEPT headers.
    #
    # @example
    #  use SenorArmando::Rack::SetContentType
    #
    class SetContentType
      include ::Rack::RespondTo
      include Goliath::Rack::AsyncMiddleware

      def initialize(app, types=nil)
        @app     = app
        ::Rack::RespondTo.media_types = types ? [types].flatten : ['json']
        @default = media_types.first
      end

      FILE_EXTENSION_RE = /\A(.*)\.([\w\-]*)\z/o

      def call(env)
        if FILE_EXTENSION_RE.match(env['PATH_INFO'])
          path, ext = [$1, $2]
          unless ::Rack::RespondTo.media_types.include?(ext)
            raise Goliath::Validation::BogusFormatError.new("Allowed formats [#{media_types.join(',')}] do not include .#{ext}")
          end
          env['PATH_INFO']     = path
          env['REQUEST_PATH']  = path
          env['HTTP_ACCEPT']   = concat_mime_type(env['HTTP_ACCEPT'], ::Rack::Mime.mime_type(".#{ext}", @default))
          env.params['format'] = ext
        end
        super(env)
      end

      def post_process(env, status, headers, body)
        ::Rack::RespondTo.env = env

        # raise Goliath::Validation::BogusFormatError.new('yo what up')

        # the respond_to block is what actually triggers the
        # setting of selected_media_type, so it's required
        respond_to do |format|
          ::Rack::RespondTo.media_types.each do |type|
            format.send(type, Proc.new { body })
          end
        end

        extra = {
          'Content-Type' => get_content_type(env),
          'Server'       => Settings.app_name,
          'Vary'         => [headers.delete('Vary'), 'Accept'].compact.join(',')
        }

        [status, extra.merge(headers), body]
      end

    private

      def media_types
        ::Rack::RespondTo.media_types
      end

      def concat_mime_type(accept, type)
        (accept || '').split(',').unshift(type).compact.join(',')
      end

      def get_content_type(env)
        type = if env.respond_to? :params
          fmt = env.params['format']
          fmt = fmt.last if fmt.is_a?(Array)

          if !fmt.nil? && fmt !~ /^\s*$/
            ::Rack::RespondTo::MediaType(fmt)
          end
        end

        type = ::Rack::RespondTo.env['HTTP_ACCEPT'] if type.nil?
        type = ::Rack::RespondTo.selected_media_type if type == '*/*'

        "#{type}; charset=utf-8"
      end
    end
  end
end
