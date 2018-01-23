# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Contact Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#contact-object
    class Contact < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :name
      attr_accessor :url
      attr_accessor :email

      def to_openapi3
        _ext_openapi3! \
          "name" => name,
          "url" => url,
          "email" => email
      end
    end
  end
end
