# frozen_string_literal: true

require "modern/open_api3/base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Contact Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#contact-object
    class Contact < Modern::OpenAPI3::Base
      Type = Modern::Types.Instance(self)

      include Modern::OpenAPI3::SpecificationExtensions

      attribute :name, Modern::Types::Strict::String.optional.default(nil)
      attribute :url, Modern::Types::Strict::String.optional.default(nil)
      attribute :email, Modern::Types::Strict::String.optional.default(nil)

      def to_openapi3
        _ext_openapi3! \
          "name" => name,
          "url" => url,
          "email" => email
      end
    end
  end
end
