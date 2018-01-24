# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Components Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#components-object
    class Components < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_reader :schemas
      attr_reader :responses
      attr_reader :parameters
      attr_reader :examples
      attr_reader :request_bodies
      attr_reader :headers
      attr_reader :security_schemes
      attr_reader :links
      attr_reader :callbacks

      def initialize
        @schemas = {}
        @responses = {}
        @parameters = {}
        @examples = {}
        @request_bodies = {}
        @headers = {}
        @security_schemes = {}
        @links = {}
        @callbacks = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "schemas" => schemas.empty? ? nil : schemas.map { |k, v| [k, v.to_openapi3] }.to_h,
          "responses" => responses.empty? ? nil : responses.map { |k, v| [k, v.to_openapi3] }.to_h,
          "parameters" => parameters.empty? ? nil : parameters.map { |k, v| [k, v.to_openapi3] }.to_h,
          "examples" => examples.empty? ? nil : examples.map { |k, v| [k, v.to_openapi3] }.to_h,
          "requestBodies" => request_bodies.empty? ? nil : request_bodies.map { |k, v| [k, v.to_openapi3] }.to_h,
          "headers" => headers.empty? ? nil : headers.map { |k, v| [k, v.to_openapi3] }.to_h,
          "securitySchemes" => security_schemes.empty? ? nil : security_schemes.map { |k, v| [k, v.to_openapi3] }.to_h,
          "links" => links.empty? ? nil : links.map { |k, v| [k, v.to_openapi3] }.to_h,
          "callbacks" => callbacks.empty? ? nil : callbacks.map { |k, v| [k, v.to_openapi3] }.to_h
      end
    end
  end
end
