# frozen_string_literal: true

require 'modern/descriptor/route'

module Modern
  class App
    class Router < Dry::Struct
      attribute :routes, Modern::Types::Strict::Array.of(
        Modern::Types.Instance(Modern::Descriptor::Route)
      )

      def initialize(inputs)
        super(inputs)

        process_routes
      end

      def resolve(http_method, path)
        # TODO: This is an O(n) matcher. We have options for improving this.
        #       - Caching most recent N URL resolutions.
        #       - Path trie. (Write the traversal iteratively.)

        http_method = http_method.to_s.upcase

        @flat_lookup[http_method].find do |r|
          r.path_matcher.match(path)
        end
      end

      private

      def process_routes
        @flat_lookup = build_flat_lookup_table(routes)
      end

      def build_flat_lookup_table(routes)
        routes.each(&:path_matcher) # to pre-build our match regexes

        ret = {}

        Modern::Types::HTTP_METHODS.each do |method_name|
          ret[method_name] =
            routes.select { |r| r.http_method.to_s.upcase == method_name }.to_a
          ret[method_name].sort! { |a, b| a.path <=> b.path }
        end

        ret
      end
    end
  end
end
