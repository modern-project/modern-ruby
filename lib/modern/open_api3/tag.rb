# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Tag Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#tag-object
    class Tag < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :name
      attr_accessor :description
      attr_accessor :external_docs

      def to_openapi3
        _ext_openapi3! \
          "name" => name,
          "description" => description,
          "externalDocs" => external_docs&.to_openapi3
      end
    end
  end
end
