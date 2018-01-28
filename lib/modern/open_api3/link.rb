# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Link Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#link-object
    class Link < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :operation_ref
      attr_accessor :operation_id
      attr_reader :parameters
      attr_accessor :request_body
      attr_accessor :description
      attr_accessor :server

      def initialize
        @parameters = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "operationRef" => operation_ref,
          "operationId" => operation_id,
          "parameters" => parameters.empty? ? nil : parameters.map { |k, v| [k, v.to_openapi3] }.to_h,
          "requestBody" => request_body,
          "description" => description,
          "server" => server&.to_openapi3
      end
    end
  end
end
