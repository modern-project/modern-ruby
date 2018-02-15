# frozen_string_literal: true

require 'modern/struct'

require 'modern/descriptor'

require 'deep_dop'
require 'docile'
require 'ice_nine'

module Modern
  module DSL
    class Scope
      NAMESPACE_REGEX = %r,[^/].+[^/],
      DEFAULT_VALUES = {
        base_path: "/",
        parameters: []
      }

      def initialize(descriptor, settings)
        @descriptor = descriptor
        @original_settings = IceNine.deep_freeze(DeepDup.deep_dup(settings))
        @settings = DEFAULT_VALUES.merge(@original_settings)
      end

      def namespace(n)
        raise "namespace segments can't begin or end with a /." \
          if NAMESPACE_REGEX.match(n)

        new_settings = @original_settings.merge(
          base_path: @original_settings[:base_path] + n
        )
      end

      def self.evaluate(descriptor, settings, &block)
        Docile.dsl_eval(Scope.new(descriptor, settings), &block)
      end
    end
  end
end
