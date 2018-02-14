# frozen_string_literal: true

require 'modern/struct'

module Modern
  module Descriptor
    def self.from(&block)
      require 'modern/dsl'

      Modern::DSL::Root.build(&block)
    end
  end
end

Dir["#{__dir__}/descriptor/**/*.rb"].each { |f| require_relative f }
