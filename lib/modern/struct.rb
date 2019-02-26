# frozen_string_literal: true

require 'deep_merge/rails_compat'
require 'dry/struct'

require 'modern/types'

module Modern
  class Struct < Dry::Struct
    module Copy
      # This implementation is necessary because the "fast" way (hash, merge, recreate)
      # WILL EAT YOUR TYPE DATA. This is the only way I can find to copy-but-change an
      # object that doesn't.
      #
      # Computers are bad.
      def copy(fields = {})
        self.class[self.class.attribute_names.map { |n| [n, self[n]] }.to_h.merge(fields)]
      end
    end

    transform_types do |type|
      type.constructor { |value| value.nil? ? Undefined : value  }
    end

    include Copy
  end
end
