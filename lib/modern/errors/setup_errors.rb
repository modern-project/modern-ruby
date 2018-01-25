# frozen_string_literal: true

require_relative './error'

module Modern
  module Errors
    class SetupError < Modern::Errors::Error; end

    class RoutingError < SetupError; end
  end
end
