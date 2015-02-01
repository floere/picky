module Picky

  module Backends

    class SQLite < Backend

      attr_reader :realtime

      def initialize options = {}
        @realtime = options[:realtime]

        require 'sqlite3'
      rescue LoadError => e
        warn_gem_missing 'sqlite3', 'SQLite bindings'
      end

      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle, _ = nil
        StringKeyArray.new bundle.index_path(:inverted), realtime: realtime
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      def create_weights bundle, _ = nil
        Value.new bundle.index_path(:weights), realtime: realtime
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle, _ = nil
        StringKeyArray.new bundle.index_path(:similarity), realtime: realtime
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle, _ = nil
        Value.new bundle.index_path(:configuration), realtime: realtime
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [id] # => [:sym1, :sym2]
      #
      def create_realtime bundle, _ = nil
        IntegerKeyArray.new bundle.index_path(:realtime), realtime: realtime
      end

    end

  end

end
