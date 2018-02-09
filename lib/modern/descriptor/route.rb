# frozen_string_literal: true

require "set"

require "modern/struct"

require "modern/descriptor/response"
require "modern/descriptor/parameters"
require "modern/descriptor/request_body"
require "modern/descriptor/security"

require "modern/util/header_parsing"

module Modern
  module Descriptor
    class Route < Modern::Struct
      Type = Types.Instance(self)

      TEMPLATE_TOKEN = /\{.+\}/
      OPENAPI_CAPTURE = %r|/\{(?<name>.+?)\}|

      attribute :id, Types::String

      attribute :http_method, Types::HttpMethod
      attribute :path, Types::HttpPath

      attribute :summary, Types::Strict::String.optional.default(nil)
      attribute :description, Types::Strict::String.optional.default(nil)
      attribute :deprecated, Types::Strict::Bool.default(false)
      attribute :tags, Types.array_of(Types::Coercible::String)

      attribute :parameters, Types.array_of(Parameters::Base::Type)
      attribute :request_body, Modern::Descriptor::RequestBody::Type.optional.default(nil)
      attribute :responses, Types.array_of(Modern::Descriptor::Response::Type)

      attribute :input_converters, Types.array_of(Modern::Descriptor::Converters::Input::Base::Type)
      attribute :output_converters, Types.array_of(Modern::Descriptor::Converters::Output::Base::Type)

      attribute :helpers, Types.array_of(Types.Instance(Module))
      attribute :action, Types::RouteAction

      attr_reader :path_matcher
      attr_reader :route_tokens

      attr_reader :content_types
      attr_reader :responses_by_code

      attr_reader :input_converters_by_type
      attr_reader :output_converters_by_type

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

        @input_converters_by_type = input_converters.map { |c| [c.media_type.downcase.strip, c] }.to_h.freeze
        @output_converters_by_type = output_converters.map { |c| [c.media_type.downcase.strip, c] }.to_h.freeze
      end
    end
  end
end
