# frozen_string_literal: true

require 'docile'

require 'modern/descriptor'

# TODO: make the DSL in general more efficient
#       The various copies in every class in this DSL builder are probably
#       unavoidable. Which is a bummer. But we could probably reduce the amount
#       of code involved. I've been trying to think of a good way to make a
#       generalized builder for Dry::Struct; anybody have a good idea?
Dir["#{__dir__}/dsl/**/*.rb"].each { |f| require_relative f }
