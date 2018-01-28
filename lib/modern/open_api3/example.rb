# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Example Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#example-object
    class Example < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :summary
      attr_accessor :description
      attr_accessor :value
      attr_accessor :external_value

      def to_openapi3
        _ext_openapi3! \
          "summary" => summary,
          "description" => description,
          "value" => value,
          "externalValue" => external_value
      end
    end
  end
end
