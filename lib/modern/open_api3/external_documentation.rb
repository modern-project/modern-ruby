# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `External Documentation Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#external-documentation-object
    class ExternalDocumentation < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :description
      attr_accessor :url

      def to_openapi3
        _ext_openapi3! \
          "description" => description,
          "url" => url
      end
    end
  end
end
