# frozen_string_literal: true

require 'json'
require 'yaml'

require 'modern/descriptor'

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

      OPENAPI_VERSION = "3.0.1"

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

      def hash(descriptor)
        ret = {
          openapi: OPENAPI_VERSION,

          info: _info(descriptor.info),
          paths: _paths(descriptor),
          components: _components(descriptor)
        }

        ret
      end

      def _info(obj)
        obj.to_h.compact
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
