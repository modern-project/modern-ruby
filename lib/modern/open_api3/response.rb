# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Response Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#response-object
    class Response < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :description
      attr_reader :headers
      attr_reader :content
      attr_reader :links

      def to_openapi3
        _ext_openapi3! \
          "description" => description,
          "headers" => headers.empty? ? nil : headers.map { |k, v| [k, v.to_openapi3] }.to_h,
          "content" => content.empty? ? nil : content.map { |k, v| [k, v.to_openapi3] }.to_h,
          "links" => links.empty? ? nil : links.map { |k, v| [k, v.to_openapi3] }.to_h
      end
    end
  end
end
