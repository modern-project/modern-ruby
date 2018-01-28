# frozen_string_literal: true

require 'dry/types'

require 'ice_nine'

module Modern
  module Types
    include Dry::Types.module

    # rubocop:disable Style/MutableConstant
    # This is left unfrozen so as to allow additional verbs to be added
    # in the future. Should be rare, but I've seen it done...
    HTTP_METHODS = %w[GET POST PUT DELETE PATCH HEAD OPTIONS TRACE]
    # rubocop:enable Style/MutableConstant

    HttpMethod = Types::Coercible::String.enum(*HTTP_METHODS)
    HttpPath = Types::Strict::String.constrained(
      format: %r,/.*,
    )

    MIMEType = Types::Strict::String.constrained(
      format: %r,\w+/[-.\w]+(?:\+[-.\w]+)?,
    )

    RouteAction = Instance(Proc)

    Type = Instance(Dry::Types::Definition)

    def self.array_of(type)
      Modern::Types::Strict::Array.of(type).default([])
    end
  end
end
