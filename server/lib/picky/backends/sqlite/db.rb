module Picky

  module Backends

    class SQLite

      class DB

        include Helpers::File

        attr_reader :cache_path, :db

        def initialize cache_path, options = {}
          @cache_path = "#{cache_path}.sqlite3"
          @empty      = options[:empty]
          @initial    = options[:initial]
          @self_indexed = options[:self_indexed]
        end

        def initial
          @initial && @initial.clone || (@self_indexed ? self : {})
        end

        def empty
          @empty && @empty.clone || (@self_indexed ? self.reset_db.asynchronous : {})
        end

        def lazily_initialize_client
          @db ||= SQLite3::Database.new cache_path
        end

        def dump_sqlite internal
          reset_db

          transaction do 
            # Note: Internal structures need to
            #       implement each.
            #
            internal.each do |key, value|
              encoded_value = Yajl::Encoder.encode value
              db.execute 'insert into key_value values (?,?)', key.to_s, encoded_value
            end
          end
        end

        def dump internal
          dump_sqlite internal unless @self_indexed
          self
        end

        def load
          lazily_initialize_client
          self
        end

        def []= key, value
          encoded_value = Yajl::Encoder.encode value

          if self[key]
            db.execute 'update key_value set value = (?) where key = (?) ', encoded_value, key.to_s
          else
            db.execute 'insert into key_value (key, value) values (?,?)', key.to_s, encoded_value
          end

          maybe_extend(value, key)
        end

        def [] key
          res = db.execute "select value from key_value where key = ? limit 1;", key.to_s
          return nil if res.empty?

          decoded = Yajl::Parser.parse res.first.first
          maybe_extend(decoded, key)
          decoded
        end

        def maybe_extend(array, key)
          return nil unless array.class == Array
          array.extend Realtime 
          array.db = self
          array.key = key
        end

        def to_s
          "#{self.class}(#{cache_path})"
        end

        module Realtime
          attr_accessor :db, :key
          def << value
            super value
            db[key] = self
          end

          def unshift value
            super value
            db[key] = self
          end
        end
          
        def reset_db 
          create_directory cache_path
          lazily_initialize_client
          db.execute 'drop table if exists key_value;'
          db.execute 'create table key_value (key varchar(255), value text);'
          db.execute 'create index key_idx on key_value (key);'
          self
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

      end

    end

  end

end
