module Picky

  module Backends

    class Sqlite3 < Backend

      require "sqlite3"

      class DB

        include Helpers::File
        attr_reader :cache_path

        def initialize(cache_path, options = {})
          @cache_path = cache_path + ".sqlite3"
          @empty      = options[:empty]
          @initial    = options[:initial]
        end

        def initial
          @initial && @initial.clone || {}
        end

        def empty
          @empty && empty.clone || {}
        end

        def dump(internal)

          puts "Writing #{cache_path}"

          create_directory cache_path

          @db = SQLite3::Database.new(cache_path)
          @db.execute <<-SQL
            drop table if exists key_value;
          SQL

          @db.execute <<-SQL
            create table key_value (
              key varchar(255),
              value text
            );
          SQL

          @db.execute <<-SQL
            create index key_idx on key_value (key);
          SQL

          @db.execute("BEGIN;")

          internal.each do |key, value|
            encoded_value = Yajl::Encoder.encode(value)
            @db.execute("insert into key_value values (?,?)", key.to_s, encoded_value)
          end

          @db.execute("COMMIT;")
        end

        def load 
          @db = SQLite3::Database.new(cache_path)
          self
        end

        def [](key)

          res = @db.execute "select value from key_value where key = ? limit 1;", key.to_s
          return nil if res.empty?

          Yajl::Parser.parse(res.first.first || "")
        end
      end

      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => [id, id, id, id, id] (an array of ids)
      #
      def create_inverted bundle
        #extract_lambda_or(inverted, bundle) ||
        DB.new(bundle.index_path(:inverted))
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:token] # => 1.23 (a weight)
      #
      def create_weights bundle
        #extract_lambda_or(weights, bundle) ||
        DB.new(bundle.index_path(:weights))
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:encoded] # => [:original, :original] (an array of original symbols this similarity encoded thing maps to)
      #
      def create_similarity bundle
        #extract_lambda_or(similarity, bundle) ||
        DB.new(bundle.index_path(:similarity))
      end
      # Returns an object that on #initial, #load returns an object that responds to:
      #   [:key] # => value (a value for this config key)
      #
      def create_configuration bundle
        #extract_lambda_or(configuration, bundle) ||
        DB.new(bundle.index_path(:configuration))
      end

      # Returns the result ids for the allocation.
      #
      # Sorts the ids by size and & through them in the following order (sizes):
      # 0. [100_000, 400, 30, 2]
      # 1. [2, 30, 400, 100_000]
      # 2. (100_000 & (400 & (30 & 2))) # => result
      #
      # Note: Uses a C-optimized intersection routine (in performant.c)
      #       for speed and memory efficiency.
      #
      # Note: In the memory based version we ignore the amount and offset hints.
      #       We cannot use the information to speed up the algorithm, unfortunately.
      #
      def ids combinations, _, _
        # Get the ids for each combination.
        #
        id_arrays = combinations.inject([]) do |total, combination|
          total << combination.ids
        end

        # Call the optimized C algorithm.
        #
        # Note: It orders the passed arrays by size.
        #
        Performant::Array.memory_efficient_intersect id_arrays
      end

    end

  end

end
