module Picky
  class Index
    
    class Hints
      
      def initialize hints
        @hints = check hints
      end
      
      # Check if all hints are allowed
      #
      @@allowed_hints = [:no_dump]
      def check hints
        hints.each do |hint|
          unless @@allowed_hints.include?(hint)
            raise <<-ERROR
              Picky cannot optimize for #{hint}.
              Allowed hints are:
                #{@@allowed_hints.join("\n")}
            ERROR
          end
        end
        hints
      end
      
      # Tells us if the user intends to e.g. not dump the indexes.
      #
      # E.g. hints.does?(:no_dump) # => true/false
      #
      def does? hint
        @hints.include? hint
      end
      
    end
    
  end
end