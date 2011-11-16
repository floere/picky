module Picky

  module Backends

    class Sqlite

      class DB

        include Helpers::File

        attr_reader :cache_path

        def initialize cache_path, options = {}
          @cache_path = "#{cache_path}.sqlite3"
          @empty      = options[:empty]
          @initial    = options[:initial]
        end

        def initial
          @initial && @initial.clone || {}
        end

        def empty
          @empty && @empty.clone || {}
        end

        def dump_sqlite internal
          @db ||= SQLite3::Database.new cache_path

          # TODO Does it make a difference if these
          #      statements are given as one to the
          #      @db.execute method?
          #

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

          @db.execute "BEGIN;"

          # Note: Internal structures need to
          #       implement each.
          #
          internal.each do |key, value|
            encoded_value = Yajl::Encoder.encode value
            @db.execute "insert into key_value values (?,?)", key.to_s, encoded_value
          end

          @db.execute "COMMIT;"
        end

        def dump internal
          create_directory cache_path
          dump_sqlite internal
        end

        def load
          @db ||= SQLite3::Database.new cache_path
          self
        end

        def [] key
          res = @db.execute "select value from key_value where key = ? limit 1;", key.to_s
          return nil if res.empty?

          # TODO Slightly speed up by not calling Yajl for the || case?
          #
          Yajl::Parser.parse res.first.first || ""
        end

        def to_s
          "#{self.class}(#{cache_path})"
        end

      end

    end

  end

end
