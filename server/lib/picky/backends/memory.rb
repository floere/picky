module Picky

  module Backends

    class Memory < Backend
      
      # TODO Make lazy.
      require_relative 'google_hash'
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle, hints = nil
        json bundle.index_path(:inverted), hash_for(hints)
      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:token] # => 1.23 (a weight)
      #
      def create_weights bundle, hints = nil
        JSON.new bundle.index_path(:weights), hash_for(hints) # GoogleHashSparseRubyToInt (I wish they had floats)
      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle, hints = nil
        Marshal.new bundle.index_path(:similarity), hash_for(hints)
      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:key] # => value (a value for this config key)
      #
      def create_configuration bundle, hints = nil
        json bundle.index_path(:configuration), hash_for(hints)
      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[id] # => [:sym1, :sym2]
      #
      def create_realtime bundle, hints = nil
        # GoogleHashSparseLongToRuby # FIXME This is only true on number keys (add Picky hints).
        json bundle.index_path(:realtime), hash_for(hints)
      end
      
      private
      
        def hash_for hints
          if hints && hints.does?(:no_dump)
            ::GoogleHashSparseRubyToRuby # TODO Use GoogleHashSparseIntToRuby where possible.
          else
            ::Hash
          end
        end

    end

  end

end