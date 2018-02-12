# frozen_string_literal: true

require 'modern/descriptor/converters/output/base'

module Modern
  module Descriptor
    module Converters
      module Output
        # We use this because we pre-bake the OpenAPI3 spec JSON and
        # want the content type. However, our route invokes
        # {Modern::Response#bypass!}, so this will never be called.
        YAMLBypass = Base.new(
          media_type: "application/yaml",
          converter: proc { raise "this should never be called!" }
        )
      end
    end
  end
end

# rubocop:enable Layout/EmptyLinesAroundArguments
