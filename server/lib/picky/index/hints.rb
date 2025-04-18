module Picky
  class Index
    class Hints
      ALLOWED_HINTS = [:no_dump].freeze

      def initialize(hints)
        @hints = check hints
      end

      # Check if all hints are allowed
      #
      def check(hints)
        hints.each do |hint|
          next if ALLOWED_HINTS.include?(hint)

          raise <<-ERROR
              Picky cannot optimize for #{hint}.
              Allowed hints are:
                #{ALLOWED_HINTS.join("\n")}
          ERROR
        end
        hints
      end

      # Tells us if the user intends to e.g. not dump the indexes.
      #
      # E.g. hints.does?(:no_dump) # => true/false
      #
      def does?(hint)
        @hints.include? hint
      end
    end
  end
end
