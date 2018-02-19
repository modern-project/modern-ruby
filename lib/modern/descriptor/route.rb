# frozen_string_literal: true

require "set"

require "modern/struct"

require "modern/descriptor/converters"
require "modern/descriptor/response"
require "modern/descriptor/parameters"
require "modern/descriptor/request_body"
require "modern/descriptor/security"

module Modern
  module Descriptor
    class Route < Modern::Struct
      # TODO: define OpenAPI-style callbacks
      TEMPLATE_TOKEN = %r|\{.+\}|
      OPENAPI_CAPTURE = %r|/\{(?<name>.+?)\}|

      attribute :id, Types::String

      attribute :http_method, Types::HttpMethod
      attribute :path, Types::HttpPath

      attribute :summary, Types::Strict::String.optional.default(nil)
      attribute :description, Types::Strict::String.optional.default(nil)
      attribute :deprecated, Types::Strict::Bool.default(false)
      attribute :tags, Types.array_of(Types::Coercible::String)

      attribute :parameters, Types.array_of(Parameters::Base)
      attribute :request_body, RequestBody.optional.default(nil)
      attribute :responses, Types.array_of(Response)

      attribute :input_converters, Types.array_of(Modern::Descriptor::Converters::Input::Base)
      attribute :output_converters, Types.array_of(Modern::Descriptor::Converters::Output::Base)

      attribute :security, Types.array_of(Security::Base)
      attribute :helpers, Types.array_of(Types.Instance(Module))
      attribute :action, Types::RouteAction

      attr_reader :path_matcher
      attr_reader :route_tokens

      attr_reader :content_types
      attr_reader :responses_by_code

      attr_reader :input_converters_by_type
      attr_reader :output_converters_by_type

      attr_reader :request_container_class

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
        # TODO: figure out how to better validate these
        #       This might be a larger-scale problem. The DSL creates a route with this, and you can end
        #       up in a case where you try to add a new content type to another response type. This causes
        #       the commented test below to fail unless you defined the :default response, with that content
        #       type, higher in the DSL. We might need some sort of intermediate builder class, or a way to
        #       squelch this error somehow...
        # require 'pry'; binding.pry
        # raise "Missing content types in default HTTP response for #{id}: #{nondefault_content.to_a.join(', ')}" \
        #     unless nondefault_content.empty?

        @input_converters_by_type = input_converters.map { |c| [c.media_type.downcase.strip, c] }.to_h.freeze
        @output_converters_by_type = output_converters.map { |c| [c.media_type.downcase.strip, c] }.to_h.freeze

        @request_container_class =
          if helpers.empty?
            Modern::App::RequestHandling::FullRequestContainer
          else
            rcc = Class.new(Modern::App::RequestHandling::FullRequestContainer)
            helpers.each { |h| rcc.send(:include, h) }

            rcc
          end
      end
    end
  end
end
