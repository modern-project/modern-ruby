require 'modern/descriptor/converters/output/base'

require 'json'

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
              retval.as_json
            elsif retval.respond_to?(:to_json)
              retval.to_json
            else
              JSON.generate(retval)
            end
          end
        )
      end
    end
  end
end
