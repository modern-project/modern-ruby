# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Info Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#info-object
    class Info < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :title
      attr_accessor :description
      attr_accessor :terms_of_service
      attr_accessor :contact
      attr_accessor :license
      attr_accessor :version

      def to_openapi3
        _ext_openapi3! \
          "title" => title,
          "description" => description,
          "termsOfService" => :terms_of_service,
          "contact" => contact.to_openapi3,
          "license" => license.to_openapi3,
          "version" => version
      end
    end
  end
end
