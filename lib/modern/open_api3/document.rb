# frozen_string_literal: true

require "modern/open_api3/base"
require "modern/open_api3/info"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `OpenAPI Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#oasObject
    class Document < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :openapi
      attr_accessor :info
      attr_reader :servers
      attr_reader :paths
      attr_accessor :components
      attr_reader :security
      attr_reader :tags
      attr_accessor :external_docs

      def initialize
        @openapi = Modern::OPENAPI_VERSION
        @info = Modern::OpenAPI3::Info.new
        @servers = []
        @paths = {}
        @security = []
        @tags = []
      end

      def to_openapi3
        _ext_openapi3! \
          "openapi" => openapi,
          "info" => info.to_openapi3,
          "servers" => servers.map(&:to_openapi3),
          "paths" => paths.map { |name, path| [name, path.to_openapi3] }.to_h,
          "components" => components&.to_openapi3,
          "security" => security.map(&:to_openapi3),
          "tags" => tags.map(&:to_openapi3),
          "externalDocs" => external_docs&.to_openapi3
      end
    end
  end
end
