# frozen_string_literal: true

module Modern
  module DocGenerator
    class OpenAPI3
      module SchemaDefaultTypes
        def _register_default_types!
          register_literal_type(Types::Strict::String,
                                type: "string")
          register_literal_type(Types::Coercible::String,
                                type: "string")

          register_literal_type(Types::Strict::Int,
                                type: "integer")
          register_literal_type(Types::Coercible::Int,
                                type: "integer")
        end
      end
    end
  end
end
