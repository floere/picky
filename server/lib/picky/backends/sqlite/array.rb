module Picky

  module Backends

    class SQLite

      class Array < Basic

        def []= key, array
          if array.empty?
            db.execute 'insert or replace into key_value (key, value) values (?,?)', key.to_s, Yajl::Encoder.encode(array)
          end

          DirectlyManipulable.make self, array, key
          array
        end

        def [] key
          res = db.execute "select value from key_value where key = ? limit 1;", key.to_s

          array = res.empty? ? [] : Yajl::Parser.parse(res.first.first)
          DirectlyManipulable.make self, array, key
          array
        end

        def delete key
          db.execute "delete from key_value where key = (?)", key.to_s
        end

      end

    end

  end

end
