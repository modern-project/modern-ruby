# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Path Item Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#path-item-object
    class PathItem < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :summary
      attr_accessor :description
      attr_accessor :get
      attr_accessor :put
      attr_accessor :post
      attr_accessor :delete
      attr_accessor :patch
      attr_reader :servers
      attr_reader :parameters

      def initialize
        @servers = []
        @parameters = []
      end

      def to_openapi3
        _ext_openapi3! \
          "summary" => summary,
          "description" => description,
          "get" => get&.to_openapi3,
          "put" => put&.to_openapi3,
          "post" => post&.to_openapi3,
          "delete" => delete&.to_openapi3,
          "patch" => patch&.to_openapi3,
          "servers" => servers.empty? ? nil : servers.map(&:to_openapi3),
          "parameters" => parameters.empty? ? nil : parameters.map(&:to_openapi3)
      end
    end
  end
end
