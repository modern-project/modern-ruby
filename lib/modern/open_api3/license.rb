# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `License Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#license-object
    class License < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :name
      attr_accessor :url

      def to_openapi3
        _ext_openapi3! \
          "name" => name,
          "url" => url
      end
    end
  end
end
