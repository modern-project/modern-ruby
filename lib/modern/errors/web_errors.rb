# frozen_string_literal: true

require "modern/errors/error"

module Modern
  module Errors
    class WebError < Modern::Errors::Error
      def status
        raise "#{self.class.name}#status must be implemented."
      end
    end

    class NotFoundError < WebError
      def initialize(msg = "Not found")
        super(msg)
      end

      def status
        404
      end
    end

    class UnsupportedMediaTypeError < WebError
      def initialize(msg)
        super(msg)
      end

      def status
        415
      end
    end

    class UnprocesseableEntity < WebError
      def initialize(msg)
        super(msg)
      end

      def status
        422
      end
    end
  end
end
