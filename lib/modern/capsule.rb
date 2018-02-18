# frozen_string_literal: true

require 'docile'

module Modern
  class Capsule
    attr_reader :block

    def initialize(&block)
      @block = block
    end

    def self.define(&block)
      Capsule.new(&block)
    end
  end
end
