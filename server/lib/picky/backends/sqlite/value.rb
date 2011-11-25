module Picky

  module Backends

    class SQLite

      class Value < Basic

        def []= key, value
          encoded_value = Yajl::Encoder.encode value

          if self[key]
            db.execute 'update key_value set value = (?) where key = (?)', encoded_value, key.to_s
          else
            db.execute 'insert into key_value (key, value) values (?,?)', key.to_s, encoded_value
          end

          value
        end

        def [] key
          res = db.execute "select value from key_value where key = ? limit 1;", key.to_s
          return nil if res.empty?

          Yajl::Parser.parse res.first.first
        end

      end

    end

  end

end
