module Picky

  module Backends

    class Backend

      attr_reader :inverted,
                  :weights,
                  :similarity,
                  :configuration

      def initialize options = {}
        @inverted      = options[:inverted]
        @weights       = options[:weights]
        @similarity    = options[:similarity]
        @configuration = options[:configuration]
      end

      #
      #
      def to_s
        "#{self.class}(#{[inverted, weights, similarity, configuration].join(', ')})"
      end

    end

  end

end