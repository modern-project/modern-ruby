# frozen_string_literal: true

require "modern/struct"
require "modern/descriptor/route"
require "modern/descriptor/converters"
require "modern/open_api3/security_scheme"

module Modern
  module Descriptor
    # The class that encapsulates all routes, along with their configuration and
    # metadata. This class can recursively include itself to mount other
    # instances inside of itself; this is used by {Modern::App} to generate
    # OpenAPI documentation and design routing accordingly.
    class Core < Modern::Struct
      attribute :info, Modern::OpenAPI3::Info::Type

      attribute :routes, Types.array_of(Modern::Descriptor::Route::Type)
      attribute :security_schemes, Types.array_of(Modern::OpenAPI3::SecurityScheme::Type)

      attribute :input_converters, Types.array_of(Modern::Descriptor::Converters::Input::Base::Type)
      attribute :output_converters, Types.array_of(Modern::Descriptor::Converters::Output::Base::Type)
    end
  end
end
