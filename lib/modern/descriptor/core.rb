# frozen_string_literal: true

require "modern/struct"
require "modern/descriptor/route"
require "modern/descriptor/security_scheme"

module Modern
  module Descriptor
    # The class that encapsulates all routes, along with their configuration and
    # metadata. This class can recursively include itself to mount other
    # instances inside of itself; this is used by {Modern::App} to generate
    # OpenAPI documentation and design routing accordingly.
    class Core < Modern::Struct
      attribute :info, Modern::Types.Instance(Modern::OpenAPI3::Info)

      attribute :routes, Modern::Types::Strict::Array.of(
        Modern::Types.Instance(Modern::Descriptor::Route)
      )
      attribute :security_schemes, Modern::Types::Strict::Array.of(
        Modern::Types.Instance(Modern::Descriptor::SecurityScheme)
      )
    end
  end
end
