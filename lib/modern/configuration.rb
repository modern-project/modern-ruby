# frozen_string_literal: true

require 'modern/struct'

module Modern
  class Configuration < Modern::Struct
    # TODO: once Modern is done, figure out sane defaults.
    attribute :show_errors, Modern::Types::Strict::Bool.default(true)
    attribute :validate_responses, Modern::Types::Strict::Bool.default(true)
  end
end
