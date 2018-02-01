# frozen_string_literal: true

module Modern
  module Util
    module HeaderParsing
      def self.parse_accept_header(value)
        # TODO: this is probably more garbage creation than necessary.
        # TODO: may poorly prioritize specificity, i.e. `text/*` over `*/*`
        # TODO: this doesn't support `;level=`, but should we bother?
        value.split(",").map do |type_declaration|
          tuple = type_declaration.strip.split(";q=")
          tuple[1] = tuple[1]&.to_f || 1.0

          tuple
        end.sort do |a, b|
          comp = a.last <=> b.last

          if comp != 0
            comp
          else
            -(a.first <=> b.first)
          end
        end.map(&:first)
      end
    end
  end
end
