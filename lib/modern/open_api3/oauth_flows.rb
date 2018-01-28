# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `OAuth Flows Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#oauth-flows-object
    class OAuthFlows < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :implicit
      attr_accessor :password
      attr_accessor :client_credentials
      attr_accessor :authorization_code

      def to_openapi3
        ret = _ext_openapi3! \
          "implicit" => implicit&.to_openapi3,
          "password" => password&.to_openapi3,
          "clientCredentials" => client_credentials&.to_openapi3,
          "authorizationCode" => authorization_code&.to_openapi3

        ret.empty? ? nil : ret
      end
    end
  end
end
