RedisIndex = Picky::Index.new(:redis) do
  key_format :to_i
  backend  Picky::Backends::Redis.new
  source   { CSVBook.all('data/books.csv') }
  category :title,
           qualifiers: %i[t title titre],
           partial: Picky::Partial::Substring.new(from: 1),
           similarity: Picky::Similarity::DoubleMetaphone.new(2)
  category :author,
           qualifiers: %i[a author auteur],
           partial: Picky::Partial::Substring.new(from: -2)
  category :year,
           qualifiers: %i[y year annee],
           partial: Picky::Partial::None.new
  category :publisher, qualifiers: %i[p publisher]
  category :subjects,  qualifiers: %i[s subject]
end
