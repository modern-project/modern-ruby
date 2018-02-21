# frozen_string_literal: true

require 'modern/descriptor/converters/output/base'

require 'json'

# it gets confused by the blank line after the retval reassignment.
# rubocop:disable Layout/EmptyLinesAroundArguments

module Modern
  module Descriptor
    module Converters
      module Output
        JSON = Base.new(
          media_type: "application/json",
          converter: proc do |_type, retval|
            retval =
              if retval.is_a?(Hash)
                retval.compact
              elsif retval.is_a?(Dry::Struct)
                retval.to_h.compact
              else
                retval
              end

            if retval.respond_to?(:as_json)
              ::JSON.generate(retval.as_json)
            elsif retval.respond_to?(:to_json)
              retval.to_json
            else
              ::JSON.generate(retval)
            end
          end
        )

        # We use this because we pre-bake the OpenAPI3 spec JSON and
        # want the content type. However, our route invokes
        # {Modern::Response#bypass!}, so this will never be called.
        JSONBypass = Base.new(
          media_type: "application/json",
          converter: proc { raise "this should never be called!" }
        )
      end
    end
  end
end

# rubocop:enable Layout/EmptyLinesAroundArguments
