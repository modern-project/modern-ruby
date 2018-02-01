module Modern
  module Descriptor
    # An input converter takes a raw HTTP request body and a
    # {Modern::Types::Type} (if one has been specified) and returns a Ruby
    # object. A JSON converter would return a hash, for example; a converter for
    # 'image/* might return an `IO` object. The results of this converter will
    # be passed to a route action.
    class Input < Modern::Struct
      Type = Modern::Types.Instance(self)

      attribute :media_type, Modern::Types::MIMEType
      attribute :converter, Modern::Types.Instance(Proc)
    end

    # An output converter takes a Ruby object and returns the raw contents of
    # an HTTP response body. A JSON converter would invoke `JSON.generate` on
    # a Ruby object to yield UTF-8 text; a binary converter would take an IO
    # and dump its contents into the HTTP stream.
    class Output < Modern::Struct
      Type = Modern::Types.Instance(self)

      attribute :media_type, Modern::Types::MIMEType
      attribute :converter, Modern::Types.Instance(Proc)
    end
  end
end
