# frozen_string_literal: true

require "modern/open_api3/base"
require "modern/open_api3/oauth_flows"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Security Scheme Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#security-scheme-object
    class SecurityScheme < Modern::OpenAPI3::Base
      Type = Modern::Types.Instance(self)

      include Modern::OpenAPI3::SpecificationExtensions

      attribute :type, Modern::Types::Strict::Symbol.enum(:api_key, :http, :oauth2, :open_id_connect)
      attribute :description, Modern::Types::Strict::String.optional.default(nil)

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

    class ApiKeySecurityScheme < SecurityScheme
      attribute :name, Modern::Types::Strict::String
      attribute :in, Modern::Types::Strict::Symbol.enum(:query, :header, :cookie)

      def initialize(opts)
        super(opts.merge(type: :api_key))
      end
    end

    class HttpSecurityScheme < SecurityScheme
      attribute :scheme, Modern::Types::Strict::String
      attribute :bearer_format, Modern::Types::Strict::String.optional.default(nil)

      def initialize(opts)
        super(opts.merge(type: :http))
      end
    end

    class OAuth2SecurityScheme < SecurityScheme
      def initialize(_opts)
        raise "TODO: implement OAuth2SecurityScheme"
        # super(opts.merge(type: :oauth2))
      end
    end

    class OpenIdConnectSecurityScheme < SecurityScheme
      def initialize(_opts)
        raise "TODO: implement OpenIdConnectSecurityScheme"
        # super(opts.merge(type: :open_id_connect))
      end
    end
  end
end
