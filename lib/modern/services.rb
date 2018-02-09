# frozen_string_literal: true

require "modern/struct"

module Modern
  # The default services catalogue for a Modern app, and one that can be
  # extended by a consuming application to add additional services. Mixins
  # and multiple services from multiple packages can be done with `dry-struct`
  # but looks a little bizarre:
  #
  # https://discourse.dry-rb.org/t/dry-struct-reusing-a-set-of-common-attributes/315/3
  class Services < Modern::Struct
    attribute :base_logger, (Types.Instance(Ougai::Logger).default { Ougai::Logger.new($stderr) })
  end
end
