# frozen_string_literal: true

require_relative './operations'

module Modern
  module DocGenerator
    class OpenAPI3
      module Paths
        include Operations

        def _paths(descriptor)
          descriptor.routes_by_path.map do |path, routes_by_method|
            [
              path,
              routes_by_method.map do |method, route|
                [method.downcase, _operation(route)]
              end.to_h
            ]
          end.to_h
        end
      end
    end
  end
end
