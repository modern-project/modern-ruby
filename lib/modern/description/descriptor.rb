# frozen_string_literal: true

require 'modern/open_api3/info'

module Modern
  module Description
    # The class that encapsulates all routes, along with their configuration and
    # metadata. This class can recursively include itself to mount other
    # instances inside of itself; this is used by {Modern::App} to generate
    # OpenAPI documentation and design routing accordingly.
    class Descriptor
      attr_reader :info

      attr_reader :routes
      attr_reader :security_schemes

      def initialize
        @info = Modern::OpenAPI3::Info.new

        @security_schemes = []
        @routes = []
      end
    end
  end
end
