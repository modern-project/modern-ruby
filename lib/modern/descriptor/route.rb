# frozen_string_literal: true

require "set"

require "modern/struct"

require "modern/descriptor/response"
require "modern/descriptor/parameters"
require "modern/descriptor/request_body"

require "modern/util/header_parsing"

module Modern
  module Descriptor
    class Route < Modern::Struct
      Type = Modern::Types.Instance(self)

      TEMPLATE_TOKEN = /\{.+\}/
      OPENAPI_CAPTURE = %r|/\{(?<name>.+?)\}|

      attribute :id, Modern::Types::String

      attribute :http_method, Modern::Types::HttpMethod
      attribute :path, Modern::Types::HttpPath

      attribute :summary, Modern::Types::Strict::String.optional.default(nil)
      attribute :description, Modern::Types::Strict::String.optional.default(nil)
      attribute :deprecated, Modern::Types::Strict::Bool.default(false)
      attribute :tags, Modern::Types.array_of(Types::Coercible::String)

      attribute :parameters, Modern::Types.array_of(Parameters::Base::Type)
      attribute :request_body, Modern::Descriptor::RequestBody::Type.optional.default(nil)
      attribute :responses, Modern::Types.array_of(Modern::Descriptor::Response::Type)

      attribute :action, Modern::Types::RouteAction

      attr_reader :path_matcher
      attr_reader :route_tokens

      attr_reader :content_types
      attr_reader :responses_by_code

      def initialize(fields)
        super(fields)

        @path_matcher = Regexp.new("^" + path.gsub(OPENAPI_CAPTURE, "/(?<\\k<name>>[^/]+)") + "$")
        @route_tokens =
          path.sub(%r|^/|, "").split("/").map do |token|
            TEMPLATE_TOKEN =~ token ? :templated : token
          end

        @content_types = responses.map { |r| r.content.map(&:media_type) }.flatten.to_set.freeze
        @responses_by_code = responses.map { |r| [r.http_code, r] }.to_h.freeze

        raise "Cannot create a Route without a Response where http_code = :default." \
          unless @responses_by_code.key?(:default)

        nondefault_content = @content_types - @responses_by_code[:default].content.map(&:media_type).to_set
        raise "Missing content types in default HTTP response for #{id}: #{nondefault_content.join(', ')}" \
            unless nondefault_content.empty?
      end
    end
  end
end
