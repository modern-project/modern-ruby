# frozen_string_literal: true

require_relative "./base"

module Modern
  module OpenAPI3
    # Corresponds to the OpenAPI 3  `Header Object`.
    #
    # https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.1.md#header-object
    class Header < Modern::OpenAPI3::Base
      include Modern::OpenAPI3::SpecificationExtensions

      attr_accessor :description
      attr_accessor :required
      attr_accessor :deprecated
      attr_accessor :allow_empty_value

      attr_accessor :style
      attr_accessor :explode
      attr_accessor :allow_reserved
      attr_accessor :schema
      attr_accessor :example
      attr_reader :examples

      attr_reader :content

      def initialize
        @examples = {}
        @content = {}
      end

      def to_openapi3
        _ext_openapi3! \
          "name" => name,
          "in" => @in,
          "description" => description,
          "required" => required.nil? ? nil : !!required,
          "deprecated" => deprecated.nil? ? nil : !!deprecated,
          "allowEmptyValue" => allow_empty_value.nil? ? nil : !!allow_empty_value,
          
          "style" => style,
          "explode" => explode.nil? ? nil : !!explode,
          "allowReserved" => allow_reserved.nil? ? nil : !!allow_reserved,
          "schema" => schema&.to_openapi3,
          "example" => example,
          "examples" => examples.empty? ? nil : examples.map { |k, v| [k, v.to_openapi3] }.to_h,

          "content" => content.empty? ? nil : content.map { |k, v| [k, v.to_openapi3] }.to_h
      end
    end
  end
end
