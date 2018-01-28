# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Request Body Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#request-body-object
    class RequestBody < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :description
      attr_reader :content
      attr_accessor :required

      def initialize
        @content = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "description" => description,
          "content" => content.map { |k, v| [k, v.to_openapi3] }.to_h,
          "required" => required.nil? ? nil : !!required
      end
    end
  end
end
