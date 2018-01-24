# frozen_string_literal: true

module Modern
  class App
    module Routing
      private

      def find_route(_request)
        # TODO: This is an O(n) matcher. We have options for improving this.
        #       - Caching most recent N URL resolutions.
        #       - Path trie. (Write the traversal iteratively.)
        nil
      end
    end
  end
end
