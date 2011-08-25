module Picky

  module Backends

    class Backend

      #
      #
      def to_s
        "#{self.class}(#{[inverted, weights, similarity, configuration].join(', ')})"
      end

    end

  end

end