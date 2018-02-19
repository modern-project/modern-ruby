# frozen_string_literal: true

require 'modern/struct'

require 'modern/capsule'
require 'modern/descriptor'

require 'deep_dup'
require 'docile'
require 'ice_nine'

module Modern
  module DSL
    class ScopeSettings < Modern::Struct
      attribute :path_segments, Types.array_of(
        Types::Strict::String.constrained(
          format: %r,[^/]+,
        )
      )

      attribute :tags, Types.array_of(Types::Strict::String)

      attribute :deprecated, Types::Strict::Bool.default(false)

      attribute :parameters, Types.array_of(Modern::Descriptor::Parameters::Base)

      attribute :default_response, Modern::Descriptor::Response.optional.default(
        Modern::Descriptor::Response.new(http_code: :default)
      )

      # TODO: this code gets way less gross when we get Types.Map
      attribute :input_converters, Types.array_of(Modern::Descriptor::Converters::Input::Base)
      attribute :output_converters, Types.array_of(Modern::Descriptor::Converters::Output::Base)

      attribute :security, Types.array_of(Modern::Descriptor::Security::Base)
      attribute :helpers, Types.array_of(Types.Instance(Module))
    end
  end
end
