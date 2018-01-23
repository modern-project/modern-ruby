# frozen_string_literal: true

module Modern
  module OpenAPI3
    module SpecificationExtensions
      def extensions
        @extensions ||= {}
      end

      private

      def _ext_openapi3!(h)
        @extensions.each_pair do |k, v|
          h["x-#{k}"] = 
            case v
            when nil, String, Numeric
              v
            when Symbol
              v.to_s
            when Array
              v.map(&:to_h)
            else
              v.to_h
            end
        end

        h.compact!
        h
      end
    end
  end
end
