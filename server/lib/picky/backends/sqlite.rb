module Picky

  module Backends

    class SQLite < Backend

      attr_reader :self_indexed

      def initialize options = {}
        @self_indexed = options[:self_indexed]

        require 'sqlite3'
      rescue LoadError => e
        warn_gem_missing 'sqlite3', 'SQLite bindings'
      end

      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle
        StringKeyArray.new bundle.index_path(:inverted), self_indexed: self_indexed
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      def create_weights bundle
        Value.new bundle.index_path(:weights), self_indexed: self_indexed
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle
        StringKeyArray.new bundle.index_path(:similarity), self_indexed: self_indexed
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle
        Value.new bundle.index_path(:configuration), self_indexed: self_indexed
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [id] # => [:sym1, :sym2]
      #
      def create_realtime bundle
        IntegerKeyArray.new bundle.index_path(:realtime), self_indexed: self_indexed
      end

    end

  end

end
