# frozen_string_literal: true

module Modern
  class Configuration
    attr_accessor :show_errors

    def initialize
      # TODO: once Modern is done, figure out sane defaults.
      @show_errors = true
    end
  end
end
