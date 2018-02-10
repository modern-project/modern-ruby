# frozen_string_literal: true

require "modern/errors/error"

module Modern
  module Errors
    class WebError < Modern::Errors::Error
      def status
        raise "#{self.class.name}#status must be implemented."
      end
    end

    class BadRequestError < WebError
      def initialize(msg = "Bad request")
        super(msg)
      end

      def status
        400
      end
    end

    class UnauthorizedError < WebError
      def initialize(msg = "Unauthorized")
        super(msg)
      end

      def status
        401
      end
    end

    class ForbiddenError < WebError
      def initialize(msg = "Forbidden")
        super(msg)
      end

      def status
        403
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

    class NotAcceptableError < WebError
      def initialize(msg = "Not acceptable (no servable content types in Accept header)")
        super(msg)
      end

      def status
        406
      end
    end

    class UnsupportedMediaTypeError < WebError
      def initialize(msg = "Unrecognized request Content-Type.")
        super(msg)
      end

      def status
        415
      end
    end

    class UnprocessableEntity < WebError
      def initialize(msg = "Recognized content-type of body, but could not parse it.")
        super(msg)
      end

      def status
        422
      end
    end
  end
end
