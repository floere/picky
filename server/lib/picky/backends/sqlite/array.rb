module Picky

  module Backends

    class SQLite

      class Array < Basic

        def []= key, value
          encoded_value = Yajl::Encoder.encode value

          if self[key]
            db.execute 'update key_value set value = (?) where key = (?)', encoded_value, key.to_s
          else
            db.execute 'insert into key_value (key, value) values (?,?)', key.to_s, encoded_value
          end

          realtime_extend(value, key)
        end

        def [] key
          res = db.execute "select value from key_value where key = ? limit 1;", key.to_s
          return nil if res.empty?

          decoded = Yajl::Parser.parse res.first.first
          realtime_extend(decoded, key)
          decoded
        end

        def delete key
          # TODO
        end

        def realtime_extend(array, key)
          array.extend Realtime
          array.db = self
          array.key = key
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

      end

    end

  end

end
