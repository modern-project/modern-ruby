# frozen_string_literal: true

require_relative "./specification_extensions"

module Modern
  module OpenAPI3
    class Base
      def to_openapi3
        raise "#{self.class.name}#to_openapi3 must be implemented."
      end
    end
  end
end
