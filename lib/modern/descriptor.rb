# frozen_string_literal: true

require 'modern/struct'

Dir["#{__dir__}/descriptor/**/*.rb"].each { |f| require_relative f }
