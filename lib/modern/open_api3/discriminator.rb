# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Discriminator Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#discriminator-object
    class Discriminator < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :property_name
      attr_reader :mapping

      def initialize
        @mapping = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "propertyName" => property_name,
          "mapping" => mapping
      end
    end
  end
end
