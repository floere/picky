module Picky

  module Backends

    class SQLite

      class IntegerKeyArray < Array

        def create_table
          db.execute 'create table key_value (key integer PRIMARY KEY, value text);'
        end

      end

    end

  end

end