# frozen_string_literal: true

require "modern/errors/error"

module Modern
  module Errors
    class SetupError < Modern::Errors::Error; end

    class RoutingError < SetupError; end
  end
end
