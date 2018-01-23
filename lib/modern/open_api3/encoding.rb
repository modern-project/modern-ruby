# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Encoding Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#encoding-object
    class Encoding < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :content_type
      attr_reader :headers
      attr_accessor :style
      attr_accessor :explode
      attr_accessor :allow_reserved

      def initialize
        @headers = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "contentType" => content_type,
          "headers" => headers.empty? ? nil : headers.map { |k, v| [k, v.to_openapi3] }.to_h,
          "style" => style,
          "explode" => explode.nil? ? nil : !!explode,
          "allowReserved" => allow_reserved.nil? ? nil : !!allow_reserved
      end
    end
  end
end
