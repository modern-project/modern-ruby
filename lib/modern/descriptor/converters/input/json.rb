require 'modern/descriptor/converters/input/base'

require 'json'

module Modern
  module Descriptor
    module Converters
      module Input
        JSON = Base.new(
          media_type: "application/json",
          converter: proc do |io|
            str = io.read
            str.empty? ? nil : ::JSON.parse(str)
          end
        )
      end
    end
  end
end
