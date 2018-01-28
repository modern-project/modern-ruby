# frozen_string_literal: true

require "dry/struct"

require "modern/core_ext/array"
require "modern/core_ext/hash"
require "modern/types"
require "modern/open_api3/specification_extensions"

module Modern
  module OpenAPI3
    class Base < Dry::Struct
      constructor_type :strict_with_defaults

      def to_openapi3
        raise "#{self.class.name}#to_openapi3 must be implemented."
      end

      def to_json
        to_h.deep_compact!.to_json
      end
    end
  end
end
