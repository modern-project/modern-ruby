# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Server Variable Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#server-variable-object
    class ServerVariable < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :default
      attr_accessor :description
      attr_reader :enum

      def initialize
        @enum = []
      end

      def to_openapi3
        _ext_openapi3! \
          "default" => default,
          "description" => description,
          "enum" => enum.empty? ? nil : enum
      end
    end
  end
end
