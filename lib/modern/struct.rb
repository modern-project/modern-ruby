# frozen_string_literal: true

require 'dry/struct'
require 'modern/types'

module Modern
  class Struct < Dry::Struct
    constructor_type :strict_with_defaults
  end
end
