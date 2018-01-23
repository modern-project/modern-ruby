# frozen_string_literal: true

require_relative "./base"
require_relative "./oauth_flows"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Security Scheme Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#security-scheme-object
    class SecurityScheme < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :type
      attr_accessor :description
      attr_accessor :name
      attr_accessor :in
      attr_accessor :scheme
      attr_accessor :bearer_format
      attr_reader :flows
      attr_accessor :openid_connect_url

      def initialize
        @flows = Modern::OpenAPI3::OAuthFlows.new
      end

      def to_openapi3
        _ext_openapi3! \
          "type" => type,
          "description" => description,
          "name" => name,
          "in" => @in,
          "scheme" => scheme,
          "bearerFormat" => bearer_format,
          "flows" => flows.to_openapi3,
          "openIdConnectUrl" => openid_connect_url
      end
    end
  end
end
