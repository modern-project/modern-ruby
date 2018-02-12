# frozen_string_literal: true

module Modern
  module DocGenerator
    class OpenAPI3
      module Operations
        def _operation(route)
          {
            operationId: route.id,
            summary: route.summary,
            description: route.description,
            deprecated: route.deprecated,
            tags: route.tags,

            security: route.security.map { |s| _security_requirement(s) },

            parameters: route.parameters.map { |p| _parameter(p) },
            requestBody: nil,
            responses:
              route.responses_by_code.map do |code, response|
                [code, _response(response)]
              end.to_h,
            callbacks: nil
          }.compact
        end

        def _security_requirement(security)
          # TODO: OAuth2
          ret = {}
          ret[security.name] = []

          ret
        end

        def _parameter(parameter)
          # TODO: this should be in the parameter class, or that logic should be here.

          parameter.to_openapi3.merge(
            schema: _build_schema_value({}, {}, parameter.type)
          )
        end

        def _response(response)
          {
            description: response.description,
            headers:
              response.headers.map do |header|
                [
                  header.name,
                  {
                    description: header.description
                  }.compact
                ]
              end.to_h,
            content:
              response.content_by_type.map do |content_type, content|
                [
                  content_type,
                  {
                    schema:
                      if content.type.nil?
                        nil
                      elsif content.type.is_a?(Class) && content.type.ancestors.include?(Dry::Struct)
                        _struct_ref(content.type)
                      else
                        # TODO: make this less wasteful
                        #       Right now, this reuses the schema walking stuff. It totally will re-walk
                        #       existing schemas as far as `content.type` will reach. Which is slower
                        #       during startup than we'd like, but it's fixable later by converting
                        #       the methods to using state (that's why `OpenAPI3` is an object in the
                        #       first place, but I wrote myself into a corner here).
                        _build_schema_value({}, {}, content.type)
                      end
                  }.compact
                ]
              end.to_h
          }.compact
        end
      end
    end
  end
end
