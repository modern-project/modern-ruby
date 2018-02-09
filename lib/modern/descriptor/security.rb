# frozen_string_literal: true

require "modern/descriptor/parameters"
require "modern/errors/web_errors"
require "modern/struct"

module Modern
  module Descriptor
    module Security
      class Base < Modern::Struct
        Type = Types.Instance(self)

        attribute :name, Types::Strict::String
        attribute :description, Types::Strict::String.optional.default(nil)
      end

      class ApiKey < Base
        Type = Types.Instance(self)

        attribute :parameter, Parameters::Base::Type
      end

      class Http < Base
        Type = Types.Instance(self)

        attribute :scheme, Types::Strict::String
      end
    end
  end
end
