# frozen_string_literal: true

module Modern
  module DocGenerator
    class OpenAPI3
      module SchemaDefaultTypes
        def _register_default_types!
          # TODO: handle all default types
          #       This misses a few types, mostly because I don't yet know how to
          #       handle them:
          #         - I don't understand the Types::Form set of types well enough.
          #         - I have not provided a DateTime mapping because you shouldn't
          #           use DateTime and I have no idea how to do so sanely.
          #         - We can't coerce Symbols, so those are out.
          [Types::String, Types::Strict::String, Types::Coercible::String].each do |t|
            register_literal_type(t, type: "string")
          end

          [Types::Integer, Types::Strict::Integer, Types::Coercible::Integer].each do |t|
            register_literal_type(t, type: "integer", format: "int64")
          end

          [
            Types::Bool, Types::Strict::Bool,
            Types::True, Types::Strict::True,
            Types::False, Types::Strict::False
          ].each do |t|
            register_literal_type(t, type: "boolean")
          end

          [Types::Float, Types::Strict::Float, Types::Coercible::Float].each do |t|
            register_literal_type(t, type: "number", format: "double")
          end

          [Types::Date, Types::Strict::Date, Types::JSON::Date].each do |t|
            register_literal_type(t, type: "string", format: "date")
          end

          [Types::Time, Types::Strict::Time, Types::JSON::Time].each do |t|
            register_literal_type(t, type: "string", format: "date")
          end

          [Types::Decimal, Types::Strict::Decimal, Types::Coercible::Decimal].each do |t|
            register_literal_type(t, type: "number")
          end
        end
      end
    end
  end
end
