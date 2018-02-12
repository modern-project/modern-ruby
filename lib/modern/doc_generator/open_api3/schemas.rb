# frozen_string_literal: true

require_relative './schema_default_types'

module Modern
  module DocGenerator
    class OpenAPI3
      module Schemas
        # TODO: make all this not awful!
        #       I am not a type theorist. I am also not a compiler writer
        #       (though I've pretended to be in my day once or twice). dry-types
        #       is a very dense language and parsing it to emit OpenAPI schemas is
        #       really, really hard for me. This is a brute-force approach. There
        #       is probably a better one. My approach is basically to allow for
        #       the registration of literal types (which serve as my terminals) and
        #       try to build rules on top of those literal types for more complex
        #       ideas.
        # TODO: parse the dry-logic in predicates to properly fill out the rest of
        #       the JSON schema

        include SchemaDefaultTypes

        def register_literal_type(type, oapi3_value)
          raise "`type` must be a Dry::Types::Type." unless type.is_a?(Dry::Types::Type)

          @type_registry[type] = oapi3_value
        end

        # Only Dry::Struct
        def _struct_schemas(descriptor)
          ret = {}
          name_to_class = {}

          descriptor.root_schemas \
                    .select { |type_or_structclass| type_or_structclass.is_a?(Class) } \
                    .each do |structclass|
            _build_struct(ret, name_to_class, structclass)
          end

          ret
        end

        def _build_struct(ret, name_to_class, structclass)
          # TODO: allow overriding the name of the struct in #/components/schemas
          #       This is actually trickier than it looks, because we need to also
          #       make it referenceable in responses/contents. It probably means an
          #       indirect mapping of classes to names and back again.

          raise "not actually a Dry::Struct class" \
            unless structclass.ancestors.include?(Dry::Struct)

          name = structclass.name.split("::").last

          if name_to_class[name] == structclass
            name
          else
            if !name_to_class[name].nil?
              raise "Duplicate schema name: '#{name}'. Only one class, regardless " \
                    "of namespace, can be called this."
            end

            ret[name] = _build_object_from_schema(ret, name_to_class, structclass.schema)
          end

          name # necessary for recursive calls in _build_schema_value
        end

        def _build_object_from_schema(ret, name_to_class, dt_schema)
          {
            type: "object",
            properties: dt_schema.map do |k, v|
              [k, _build_schema_value(ret, name_to_class, v)]
            end.to_h
          }
        end

        def _struct_ref(structclass)
          { "$ref": "#/components/schemas/#{structclass.name.split('::').last}" }
        end

        def _build_schema_value(ret, name_to_class, entry)
          registered_type = @type_registry[entry]

          if !registered_type.nil?
            registered_type
          elsif entry.is_a?(Dry::Types::Sum::Constrained)
            if entry.left.type.primitive == NilClass
              # it's a nullable field
              _build_schema_value(ret, name_to_class, entry.right).merge(nullable: true)
            else
              {
                anyOf: _flatten_any_of(
                  [
                    _build_schema_value(ret, name_to_class, entry.left),
                    _build_schema_value(ret, name_to_class, entry.right)
                  ]
                )
              }
            end
          elsif entry.is_a?(Dry::Types::Constrained)
            # TODO: dig deeper into the actual behavior of Constrained (dry-logic)
            #       This is probably a can of worms. More:
            #       http://dry-rb.org/gems/dry-types/constraints/

            _build_schema_value(ret, name_to_class, entry.type)
          elsif entry.is_a?(Dry::Types::Default)
            # this just unwraps the default value
            _build_schema_value(ret, name_to_class, entry.type)
          elsif entry.is_a?(Dry::Types::Definition)
            primitive = entry.primitive

            if primitive.ancestors.include?(Dry::Struct)
              # TODO: make sure I'm understanding this correctly
              #       It feels weird to have to oneOf a $ref, but I can't figure out a
              #       syntax that doesn't require it.
              _build_struct(ret, name_to_class, primitive)

              {
                oneOf: [
                  _struct_ref(primitive)
                ]
              }
            elsif primitive.ancestors.include?(Hash)
              _build_object_from_schema(ret, name_to_class, entry.member_types)
            elsif primitive.ancestors.include?(Array)
              {
                type: "array",
                items: _build_schema_value(ret, name_to_class, entry.member)
              }
            else
              raise "unrecognized primitive definition '#{primitive.name}'; probably needs a literal."
            end
          else
            raise "Unrecognized schema class: #{entry.class.name}: #{entry.inspect}"
          end
        end

        def _flatten_any_of(typehash_array)
          # This is hacky, but it removes the incidence of something like this:
          #
          # :exsub => {
          #   :anyOf => [
          #       [0] {
          #           :oneOf => [
          #               [0] {
          #                   :$ref => "#/components/schemas/ExclusiveSubA"
          #               }
          #           ]
          #       },
          #       [1] {
          #           :oneOf => [
          #               [0] {
          #                   :$ref => "#/components/schemas/ExclusiveSubB"
          #               }
          #           ]
          #       }
          #   ]
          # }

          typehash_array.map do |typehash|
            if typehash.length == 1 && typehash.first.first == :oneOf
              typehash.first.last
            else
              typehash
            end
          end.flatten
        end
      end
    end
  end
end
