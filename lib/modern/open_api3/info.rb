# frozen_string_literal: true

require "modern/open_api3/base"
require "modern/open_api3/contact"
require "modern/open_api3/license"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Info Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#info-object
    class Info < Modern::OpenAPI3::Base
      Type = Types.Instance(self)

      include Modern::OpenAPI3::SpecificationExtensions

      attribute :title, Types::Strict::String
      attribute :description, Types::Strict::String.optional.default(nil)
      attribute :terms_of_service, Types::Strict::String.optional.default(nil)
      attribute :contact, OpenAPI3::Contact::Type.optional.default(nil)
      attribute :license, OpenAPI3::License::Type.optional.default(nil)
      attribute :version, Types::Strict::String

      def to_openapi3
        _ext_openapi3! \
          "title" => title,
          "description" => description,
          "termsOfService" => terms_of_service,
          "contact" => contact.to_openapi3,
          "license" => license.to_openapi3,
          "version" => version
      end
    end
  end
end
