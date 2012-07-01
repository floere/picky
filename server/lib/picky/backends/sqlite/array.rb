module Picky

  module Backends

    class SQLite

      class Array < Basic

        def create_table
          db.execute 'create table key_value (key varchar(255), value text);'
        end

        def size
          result = db.execute 'SELECT COUNT(*) FROM key_value'
          result.first.first.to_i
        end

        def []= key, array
          unless array.empty?
            db.execute 'INSERT OR REPLACE INTO key_value (key,value) VALUES (?,?)',
                       key.to_s,
                       MultiJson.encode(array)
          end

          DirectlyManipulable.make self, array, key
          array
        end

        def [] key
          res = db.execute "SELECT value FROM key_value WHERE key = ? LIMIT 1",
                           key.to_s

          array = res.blank? ? [] : MultiJson.decode(res.first.first)
          DirectlyManipulable.make self, array, key
          array
        end

        def delete key
          db.execute "DELETE FROM key_value WHERE key = (?)", key.to_s
        end

      end

    end

  end

end
