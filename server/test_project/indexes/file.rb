FileIndex = Picky::Index.new(:file) do
  key_format :to_i
  
  backend  Picky::Backends::File.new
  source [
    ChangingItem.new('1', 'first entry'),
    ChangingItem.new('2', 'second entry'),
    ChangingItem.new('3', 'third entry')
  ]
  category :name,
           partial: Picky::Partial::Infix.new(min: -3)
end