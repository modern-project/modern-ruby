# frozen_string_literal: true

require 'deep_merge/rails_compat'
require 'dry/struct'

require 'modern/types'

module Modern
  class Struct < Dry::Struct
    module Copy
      def copy(fields = {})
        self.class.new(to_h.merge(fields))
      end

      def deep_copy(fields = {})
        self.class.new(to_h.deeper_merge(fields))
      end
    end

    constructor_type :strict_with_defaults

    include Copy
  end
end
