# frozen_string_literal: true

require "modern/struct"
require "modern/descriptor/response"

module Modern
  module Descriptor
    class Route < Modern::Struct
      TEMPLATE_TOKEN = /\{.+\}/
      OPENAPI_CAPTURE = %r|/\{(?<name>.+)\}|

      attribute :id, Modern::Types::String
      attribute :http_method, Modern::Types::HttpMethod

      attribute :path, Modern::Types::HttpPath
      attribute :summary, Modern::Types::Strict::String.optional.default(nil)
      attribute :description, Modern::Types::Strict::String.optional.default(nil)

      attribute :tags, Modern::Types::RouteTags.optional.default([])
      # attribute :responses, Modern::Types::Strict::Array[Modern::Descriptor::Response].default[[]]

      def path_matcher
        @path_matcher ||= Regexp.new("^" + path.gsub(OPENAPI_CAPTURE, "/(?<\\k<name>>[^/]+)") + "$")
      end

      def route_tokens
        @route_tokens ||=
          path.sub(%r|^/|, "").split("/").map do |token|
            TEMPLATE_TOKEN =~ token ? :templated : token
          end
      end
    end
  end
end
