# frozen_string_literal: true

module Modern
  module OpenAPI3
    # Corresponds to a JSON reference in the OpenAPI3 document.
    class Ref
      attr_reader :path

      def initialize(path = nil)
        @path = path
      end

      def to_openapi3
        { "$ref": path }
      end
    end
  end
end
