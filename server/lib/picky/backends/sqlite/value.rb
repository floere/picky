module Picky

  module Backends

    class SQLite

      class Value < Basic

        def []= key, value
          db.execute 'insert or replace into key_value (key, value) values (?,?)',
                     key.to_s,
                     Yajl::Encoder.encode(value)

          value
        end

        def [] key
          res = db.execute "select value from key_value where key = ? limit 1;", key.to_s
          return nil if res.empty?

          Yajl::Parser.parse res.first.first
        end

        def delete key
          db.execute "delete from key_value where key = (?)", key.to_s
        end

      end

    end

  end

end
