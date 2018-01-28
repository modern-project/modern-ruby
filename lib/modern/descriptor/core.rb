# frozen_string_literal: true

require "modern/struct"
require "modern/descriptor/route"

module Modern
  module Descriptor
    # The class that encapsulates all routes, along with their configuration and
    # metadata. This class can recursively include itself to mount other
    # instances inside of itself; this is used by {Modern::App} to generate
    # OpenAPI documentation and design routing accordingly.
    class Core
      attr_reader :info

      attr_reader :routes
      attr_reader :security_schemes

      def initialize
        @info = Modern::OpenAPI3::Info.new

        @security_schemes = []
        @routes = []
      end

      def add_route(route)
        raise "`route` must be a Modern::Descriptor::Route." \
          unless route.is_a?(Modern::Descriptor::Route)

        @routes << route
      end
    end
  end
end
