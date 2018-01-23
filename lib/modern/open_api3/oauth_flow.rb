# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `OAuth Flow Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#oauth-flow-object
    class OAuthFlow < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :authorization_url
      attr_accessor :token_url
      attr_accessor :refresh_url
      attr_reader :scopes

      def initialize
        @scopes = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "authorizationUrl" => authorization_url,
          "tokenUrl" => token_url,
          "refreshUrl" => refresh_url,
          "scopes" => scopes
      end
    end
  end
end
