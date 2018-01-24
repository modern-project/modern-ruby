# frozen_string_literal: true

require "modern/struct"

module Modern
  class Descriptor
    class Route < Modern::Struct
      OPENAPI_CAPTURE = %r|/\{(?<name>.+)\}|

      attribute :id, Modern::Types::String
      attribute :http_method, Modern::Types::HttpMethod

      attribute :path, Modern::Types::HttpPath
      attribute :summary, Modern::Types::Strict::String.optional.default(nil)
      attribute :description, Modern::Types::Strict::String.optional.default(nil)

      attribute :tags, Modern::Types::RouteTags.optional.default([])
      attribute :action, Modern::Types::RouteAction

      def path_matcher
        @path_matcher ||= Regexp.new("^" + path.gsub(OPENAPI_CAPTURE, "/(?<\\k<name>>[^/]+)") + "$")
      end
    end
  end
end
