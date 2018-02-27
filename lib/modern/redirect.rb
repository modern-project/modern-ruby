# frozen_string_literal: true

module Modern
  # rubocop:disable Lint/InheritException
  class Redirect < Exception
    attr_reader :redirect_to

    def initialize(redirect_to)
      raise "Redirects require a target." if redirect_to.nil?
      @redirect_to = redirect_to
    end

    def status
      raise "#{self.class.name}#status must be implemented."
    end
  end
  # rubocop:enable Lint/InheritException

  class PermanentRedirect < Redirect
    def status
      308
    end
  end

  class TemporaryRedirect < Redirect
    def status
      307
    end
  end
end
