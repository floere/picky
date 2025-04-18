SQLiteItem = Struct.new :id, :first_name, :last_name
SQLiteIndex = Picky::Index.new :sqlite do
  key_format :to_i
  backend Picky::Backends::SQLite.new
  source do
    [
      SQLiteItem.new(1, 'hello', 'sqlite'),
      SQLiteItem.new(2, 'bingo', 'bongo')
    ]
  end
  category :first_name
  category :last_name
end
