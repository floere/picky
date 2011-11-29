module Picky

  module Generators

    class Strategy

      # By default, all caches are saved in a
      # storage (like a file).
      #
      # TODO Move to the backends?
      #
      def saved?
        true
      end

      def to_s
        self.class
      end

    end

  end

end