# frozen_string_literal: true

require "set"

require "modern/struct"

require "modern/core_ext/array"

require "modern/descriptor/info"
require "modern/descriptor/converters"
require "modern/descriptor/route"

module Modern
  module Descriptor
    # The class that encapsulates all routes, along with their configuration and
    # metadata. This class can recursively include itself to mount other
    # instances inside of itself; this is used by {Modern::App} to generate
    # OpenAPI documentation and design routing accordingly.
    class Core < Modern::Struct
      attribute :info, Modern::Descriptor::Info::Type

      attribute :routes, Types.array_of(Modern::Descriptor::Route::Type)

      attribute :input_converters, Types.array_of(Modern::Descriptor::Converters::Input::Base::Type)
      attribute :output_converters, Types.array_of(Modern::Descriptor::Converters::Output::Base::Type)

      attr_reader :securities_by_name
      attr_reader :root_schemas
      attr_reader :routes_by_path

      def initialize(fields)
        super

        securities = routes.map(&:security).flatten.uniq
        duplicate_names = securities.map(&:name).duplicates

        raise "Duplicate but not identical securities by names: #{duplicate_names.join(', ')}" \
          unless duplicate_names.empty?

        @securities_by_name = securities.map { |s| [s.name, s] }.to_h.freeze

        # This could be a set, but I like being able to just pull values in debug and this is
        # only iterated over.
        @root_schemas =
          routes.map do |route|
            [
              route.request_body&.type,
              route.responses.map(&:content).flatten.map(&:type)
            ]
          end.flatten.compact.uniq.freeze

        @routes_by_path = {}
        routes.each do |route|
          @routes_by_path[route.path] ||= {}
          @routes_by_path[route.path][route.http_method] = route
        end
        @routes_by_path.freeze
      end
    end
  end
end
