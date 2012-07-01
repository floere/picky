module Picky

  module Backends

    class SQLite

      class Value < Basic

        def create_table
          db.execute 'create table key_value (key varchar(255) PRIMARY KEY, value text);'
        end

        def []= key, value
          db.execute 'INSERT OR REPLACE INTO key_value (key, value) VALUES (?,?)',
                     key.to_s,
                     MultiJson.encode(value)

          value
        end

        def [] key
          res = db.execute "SELECT value FROM key_value WHERE key = ? LIMIT 1;", key.to_s
          return nil if res.empty?

          MultiJson.decode res.first.first
        end

        def delete key
          db.execute "DELETE FROM key_value WHERE key = (?)", key.to_s
        end

      end

    end

  end

end
