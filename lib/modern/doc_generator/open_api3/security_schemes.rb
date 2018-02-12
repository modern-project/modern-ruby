# frozen_string_literal: true

module Modern
  module DocGenerator
    class OpenAPI3
      module Schemas
        def _security_schemes(descriptor)
          descriptor.securities_by_name.map do |name, security|
            [name, security.to_openapi3.compact]
          end.to_h
        end
      end
    end
  end
end
