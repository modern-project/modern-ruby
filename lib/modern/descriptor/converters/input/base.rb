# frozen_string_literal: true

require 'content-type'

module Modern
  module Descriptor
    module Converters
      module Input
        # An input converter takes a raw HTTP request body (as a `StringIO`) and
        # returns a Ruby object. A JSON converter would return a hash, for
        # example; a converter for 'image/* might return the `StringIO` object
        # without alteration. The results of this converter will be passed into
        # against a {Modern::Types::Type} if one has been provided (which will
        # cause a validation check) before being passed into the route action.
        class Base < Modern::Struct
          Type = Types.Instance(self)

          attr_reader :content_type

          def initialize(fields)
            super
            @content_type = ContentType.parse(media_type).freeze
          end

          attribute :media_type, Types::MIMEType
          attribute :converter, Types.Instance(Proc)
        end
      end
    end
  end
end
