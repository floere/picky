module Picky

  module Backends

    class Memory < Backend
      
      # TODO Make lazy.
      require 'google_hash'
      
      class ::GoogleHashSparseRubyToRuby

        # This is mainly used in tests, which is
        # why we allow for a silly implementation.
        #
        def == hash
          return false unless hash.respond_to?(:to_h)
          
          self.each do |key, value|
            return false if hash[key] != value
          end
          hash.each do |key, value|
            return false if self[key] != value
          end
          
          true
        end
        
        # I am a hashy thing.
        #
        def to_hash
          true
        end
        
        #
        #
        def inject init, &block
          result = init
          each do |key, value|
            result = block.call result, [key, value]
          end
          result
        end
        
        def size
          result = 0
          # each only accepts a block
          each { result += 1 }
          result
        end

      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle
        json bundle.index_path(:inverted), GoogleHashSparseRubyToRuby
      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:token] # => 1.23 (a weight)
      #
      def create_weights bundle
        JSON.new bundle.index_path(:weights), GoogleHashSparseRubyToRuby # GoogleHashSparseRubyToInt (I wish they had floats)
      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle
        Marshal.new bundle.index_path(:similarity), GoogleHashSparseRubyToRuby
      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[:key] # => value (a value for this config key)
      #
      def create_configuration bundle
        json bundle.index_path(:configuration), GoogleHashSparseRubyToRuby
      end
      
      # Returns an object that on #initial, #load returns
      # an object that responds to:
      #   object[id] # => [:sym1, :sym2]
      #
      def create_realtime bundle
        json bundle.index_path(:realtime), GoogleHashSparseRubyToRuby # GoogleHashSparseLongToRuby # FIXME This is only true on number keys (add Picky hints).
      end

    end

  end

end