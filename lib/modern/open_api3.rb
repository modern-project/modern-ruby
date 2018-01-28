# frozen_string_literal: true

require "modern/open_api3/base"

Dir["#{__dir__}/open_api3/*.rb"].each { |f| require_relative f }
