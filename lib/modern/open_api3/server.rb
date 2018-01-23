# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Server Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#server-object
    class Server < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :url
      attr_accessor :description
      attr_reader :variables

      def initialize
        @variables = []
      end

      def to_openapi3
        _ext_openapi3! \
          "url" => url,
          "description" => description,
          "variables" => variables.map(&:to_openapi3)
      end
    end
  end
end
