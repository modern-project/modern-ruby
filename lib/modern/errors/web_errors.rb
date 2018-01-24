# frozen_string_literal: true

require_relative './error'

module Modern
  module Errors
    class WebError < Modern::Errors::Error
      def status
        raise "#{self.class.name}#status must be implemented."
      end
    end

    class NotFoundError < WebError
      def initialize(msg = "Not found")
        super
      end

      def status
        404
      end
    end
  end
end
