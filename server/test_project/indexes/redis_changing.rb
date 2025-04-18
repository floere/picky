RedisChangingIndex = Picky::Index.new(:redis_changing) do
  key_format :to_i
  backend Picky::Backends::Redis.new
  source [
    ChangingItem.new('1', 'first entry'),
    ChangingItem.new('2', 'second entry'),
    ChangingItem.new('3', 'third entry')
  ]
  category :name
end