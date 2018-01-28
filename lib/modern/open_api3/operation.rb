# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Operation Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#operation-object
    class Operation < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_reader :tags
      attr_accessor :summary
      attr_accessor :description
      attr_accessor :external_docs
      attr_accessor :operation_id
      attr_reader :parameters
      attr_accessor :request_body
      attr_reader :responses
      attr_reader :callbacks
      attr_accessor :deprecated
      attr_reader :security
      attr_accessor :no_security
      attr_reader :servers

      def initialize
        @tags = []
        @parameters = []
        @responses = {}
        @callbacks = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "tags" => tags,
          "summary" => summary,
          "description" => description,
          "externalDocs" => external_docs&.to_openapi3,
          "operationId" => operation_id,
          "parameters" => parameters.empty? ? nil : parameters.map(&:to_openapi3),
          "requestBody" => request_body&.to_openapi3,
          "responses" => responses.map { |k, v| [k, v.to_openapi3] }.to_h,
          "callbacks" => callbacks.empty? ? nil : callbacks.map { |k, v| [k, v.to_openapi3] }.to_h,
          "deprecated" => deprecated.nil? ? nil : !!deprecated,
          "security" =>
            if no_security
              nil
            else
              security.map(&:to_openapi3)
            end,
          "servers" => servers.empty? ? nil : servers.map(&:to_openapi3)
      end
    end
  end
end
