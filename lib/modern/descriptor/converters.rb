# frozen_string_literal: true

Dir["#{__dir__}/converters/input/**/*.rb"].each { |f| require_relative f }
Dir["#{__dir__}/converters/output/**/*.rb"].each { |f| require_relative f }
