# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Media Type Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#media-type-object
    class MediaType < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      # TODO: implement Schema object, not just a raw hash (too complex right now)
      attr_accessor :schema
      attr_accessor :example
      attr_reader :examples
      attr_reader :encoding

      def initialize
        @examples = {}
        @encoding = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "schema" => schema,
          "example" => example,
          "examples" => examples.empty? ? nil : examples.map { |k, v| [k, v.to_openapi3] }.to_h,
          "encoding" => encoding.empty? ? nil : encoding.map { |k, v| [k, v.to_openapi3] }.to_h
      end
    end
  end
end
