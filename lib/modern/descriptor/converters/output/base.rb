module Modern
  module Descriptor
    module Converters
      module Output
        # An output converter takes a Ruby object and returns the raw contents of
        # an HTTP response body. A JSON converter would invoke `JSON.generate` on
        # a Ruby object to yield UTF-8 text; a binary converter would take an IO
        # and dump its contents into the HTTP stream.
        class Base < Modern::Struct
          Type = Modern::Types.Instance(self)

          attr_reader :content_type

          def initialize(fields)
            super
            @content_type = ContentType.parse(media_type).freeze
          end

          attribute :media_type, Modern::Types::MIMEType
          attribute :converter, Modern::Types.Instance(Proc)
        end
      end
    end
  end
end
