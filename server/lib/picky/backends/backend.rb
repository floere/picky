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

      def extract_lambda_or thing, *args
        thing && (thing.respond_to?(:call) && thing.call(*args) || thing)
      end

      # Backends are comparable through their class.
      #
      def <=> other
        self.class <=> other.class
      end

      #
      #
      def to_s
        self.class.name
      end

    end

  end

end