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
      end

      def resolve(_http_method, _path)
        raise "#{self.class.name}#resolve must be implemented."
      end

      private

      def process_routes
        raise "#{self.class.name}#process_routes must be implemented."
      end
    end
  end
end
