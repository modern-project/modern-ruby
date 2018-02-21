# frozen_string_literal: true

require 'json'
require 'yaml'

require 'modern/descriptor'
require 'modern/descriptor/converters'

require 'modern/version'

Dir["#{__dir__}/open_api3/*.rb"].each { |f| require_relative f }

module Modern
  module DocGenerator
    class OpenAPI3
      include Schemas
      include Paths

      # TODO: this is pretty inflexible. Eventually, consumers may want to
      #       subclass Route, Content, etc., for their own use cases, and that
      #       would make using an external/visiting doc generator impractical.
      #       It's simple enough, though, so let's roll with it for now.

      OPENAPI_VERSION = Modern::OPENAPI_VERSION

      def initialize
        @type_registry = {}
        _register_default_types!
      end

      def json(descriptor)
        JSON.pretty_generate(hash(descriptor))
      end

      def yaml(descriptor)
        # TODO: this hack exists just to de-symbolize the output without spending
        #       a bunch of time on it, because we don't have ActiveSupport and
        #       #deep_stringify_keys. It happens once at startup, it's not a big
        #       deal.
        YAML.dump(JSON.parse(json(descriptor)))
      end

      def both(descriptor)
        h = hash(descriptor)
        j = JSON.pretty_generate(hash(descriptor))

        {
          json: j,
          yaml: YAML.dump(JSON.parse(j))
        }
      end

      def hash(descriptor)
        ret = {
          openapi: OPENAPI_VERSION,

          info: _info(descriptor.info),
          servers: descriptor.servers.empty? ? nil : descriptor.servers.map(&:to_h),
          paths: _paths(descriptor),
          components: _components(descriptor)
        }.compact

        ret
      end

      def decorate_with_openapi_routes(configuration, descriptor)
        docs = both(descriptor)

        openapi3_json = docs[:json].freeze
        openapi3_yaml = docs[:yaml].freeze

        serve_json = Modern::Descriptor::Route.new(
          id: "serveOpenApi3Json",
          http_method: :GET,
          path: configuration.open_api_json_path,
          summary: "Serves the OpenAPI3 application spec in JSON form.",
          responses: [
            Modern::Descriptor::Response.new(
              http_code: :default,
              content: [Modern::Descriptor::Content.new(media_type: "application/json")]
            )
          ],
          output_converters: [
            Modern::Descriptor::Converters::Output::JSONBypass
          ],
          action:
            proc do
              response.bypass!
              response.write(openapi3_json)
            end
        )

        serve_yaml = Modern::Descriptor::Route.new(
          id: "serveOpenApi3Yaml",
          http_method: :GET,
          path: configuration.open_api_yaml_path,
          summary: "Serves the OpenAPI3 application spec in YAML form.",
          responses: [
            Modern::Descriptor::Response.new(
              http_code: :default,
              content: [Modern::Descriptor::Content.new(media_type: "application/yaml")]
            )
          ],
          output_converters: [
            Modern::Descriptor::Converters::Output::YAMLBypass
          ],
          action:
            proc do
              response.bypass!
              response.write(openapi3_yaml)
            end
        )

        [serve_json, serve_yaml, descriptor.routes].flatten
      end

      def _info(obj)
        obj.to_h.compact
      end

      def _servers(obj)
      end

      def _components(descriptor)
        # TODO: figure out if we can omit the empty hashes below. We're probably never
        #       going to emit a "minimal" doc; I can't see ever trying to dedupe request
        #       bodies or whatever. (We do security schemes because it's easier and we
        #       do schemas to provide a reason for using dry-struct over a bunch of
        #       hashes.)
        ret = {
          schemas: _struct_schemas(descriptor),
          responses: {},
          parameters: {},
          examples: {},
          requestBodies: {},
          securitySchemes: _security_schemes(descriptor),
          links: {},
          callbacks: {}
        }

        ret
      end
    end
  end
end
