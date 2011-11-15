module Picky

  module Backends

    class Sqlite
      
      class DB

        include Helpers::File
        attr_reader :cache_path

        def initialize(cache_path, options = {})
          @cache_path = "#{cache_path}.sqlite3"
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
      
    end
  end
end
