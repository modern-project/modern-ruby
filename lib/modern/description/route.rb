# frozen_string_literal: true

module Modern
  module Description
    class Route
      attr_accessor :id
      attr_accessor :method
      attr_accessor :path
      attr_accessor :summary
      attr_accessor :description
      attr_reader :tags
      attr_accessor :action

      def initialize
        @tags = []
      end
    end
  end
end
