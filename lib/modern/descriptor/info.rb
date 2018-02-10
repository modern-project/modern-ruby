# frozen_string_literal: true

require "modern/struct"

module Modern
  module Descriptor
    class Info < Modern::Struct
      class Contact < Modern::Struct
        Type = Types.Instance(self)

        attribute :name, Types::Strict::String.optional.default(nil)
        attribute :url, Types::Strict::String.optional.default(nil)
        attribute :email, Types::Strict::String.optional.default(nil)
      end

      class License < Modern::Struct
        Type = Types.Instance(self)

        attribute :name, Types::Strict::String
        attribute :url, Types::Strict::String.optional.default(nil)
      end

      Type = Types.Instance(self)

      attribute :title, Types::Strict::String
      attribute :description, Types::Strict::String.optional.default(nil)
      attribute :terms_of_service, Types::Strict::String.optional.default(nil)
      attribute :contact, Contact::Type.optional.default(nil)
      attribute :license, License::Type.optional.default(nil)
      attribute :version, Types::Strict::String
    end
  end
end
