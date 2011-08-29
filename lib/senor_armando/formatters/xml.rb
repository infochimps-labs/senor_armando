require 'rack'
require 'gorillib/serialization'
require 'active_support/core_ext/hash/conversions'
require 'active_support/core_ext/array/conversions'

module SenorArmando
  module Formatters
    # A XML formatter. Attempts to convert your data into
    # an XML document.
    #
    # @example
    #   use SenorArmando::Formatters::XML
    class XML
      attr_reader :opts

      def initialize(opts={})
        @opts = opts.reverse_merge( :root => 'results', :children => 'item' )
      end

      def applies_format?(headers)
        headers['Content-Type'] =~ %r{^application/xml}
      end

      def format(content)
        content.to_wire.to_xml(opts)
      end

      def simple_format(content)
        [
          xml_header(opts[:root]),
          to_xml(content),
          xml_footer(opts[:root]),
        ].join('')
      end

    protected

      def to_xml(content)
        case
        when content.respond_to?(:each_pair) then hash_to_xml(content)
        when content.respond_to?(:each)      then array_to_xml(content, @opts[:children])
        else                                      string_to_xml(content.to_s)
        end
      end

      def string_to_xml(content)
        ::Rack::Utils.escape_html(content.to_s)
      end

      def hash_to_xml(content)
        xml_string = ''
        if content.key?('meta')
          xml_string += xml_item('meta', content['meta'])
          content.delete('meta')
        end

        content.each_pair{|key, value| xml_string << xml_item(key, value) }
        xml_string
      end

      def array_to_xml(content, item)
        content.map{|value| xml_item(item, value) }.join('')
      end

      def xml_header(root)
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<#{root}>"
      end

      def xml_footer(root)
        "</#{root}>"
      end

      def xml_item(key, value)
        key = key.to_s.gsub(/[^\w\-\.]+/, '')
        "<#{key}>#{to_xml(value)}</#{key}>\n"
      end
    end
  end
end
