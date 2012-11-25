MemoryChangingIndex = Picky::Index.new(:memory_changing) do
  source [
    ChangingItem.new("1", 'first entry'),
    ChangingItem.new("2", 'second entry'),
    ChangingItem.new("3", 'third entry')
  ]
  category :name
end