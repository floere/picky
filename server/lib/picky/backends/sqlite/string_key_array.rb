module Picky

  module Backends

    class SQLite

      class StringKeyArray < Array

        def create_table
          db.execute 'create table key_value (key varchar(255) PRIMARY KEY, value text);'
        end

      end

    end

  end

end