module Picky

  module Backends

    class SQLite

      class Basic

        include Helpers::File

        attr_reader :cache_path, :db

        def initialize cache_path, options = {}
          @cache_path = "#{cache_path}.sqlite3"
          @empty      = options[:empty]
          @initial    = options[:initial]
          @realtime   = options[:realtime]
        
          # Note: If on OSX, too many files get opened during
          #       the specs -> ulimit -n 3000
          #  
          # rescue SQLite3::CantOpenException => e
          #  
        end

        def initial
          @initial && @initial.clone || (@realtime ? self.reset : {})
        end

        def empty
          @empty && @empty.clone || (@realtime ? self.reset.asynchronous : {})
        end

        def dump internal
          dump_sqlite internal unless @realtime
          self
        end

        def load _
          self
        end

        def clear
          db.execute 'delete from key_value'
        end
        
        # Lazily creates SQLite client.
        # Note: Perhaps it would be advisable to create only one, when initialising.
        #
        def db
          @db ||= (create_directory cache_path; SQLite3::Database.new cache_path)
        end

        def dump_sqlite internal
          reset

          transaction do
            # Note: Internal structures need to
            #       implement each.
            #
            internal.each do |key, value|
              encoded_value = MultiJson.encode value
              db.execute 'insert into key_value values (?,?)', key.to_s, encoded_value
            end
          end
        end

        def reset
          truncate_db
          self
        end

        # Drops the table and creates it anew.
        #
        # THINK Could this be replaced by a truncate (DELETE FROM) statement?
        #
        def truncate_db
          drop_table
          create_table
        end

        def drop_table
          db.execute 'drop table if exists key_value;'
        end

        def asynchronous
          db.execute 'PRAGMA synchronous = OFF;'
          self
        end

        def synchronous
          db.execute 'PRAGMA synchronous = ON;'
          self
        end

        def transaction
          db.execute 'BEGIN;'
          yield
          db.execute 'COMMIT;'
        end

        def to_s
          "#{self.class}(#{cache_path})"
        end

      end

    end

  end

end
