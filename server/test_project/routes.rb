# encoding: utf-8
#

class BookSearch
  
  include Picky
  
  weights = {
    [:author]         => +6,
    [:title, :author] => +5,
    [:author, :year]  => +2
  }

  map 'books', Search.new(BooksIndex, ISBNIndex) {
    boost weights
  }
  map 'books_ignoring', Search.new(BooksIndex, ISBNIndex) {
    boost weights
    ignore_unassigned_tokens true
  }
  map 'book_each', Search.new(BookEachIndex) {
    boost weights
    # ignore :title
  }
  map 'redis', Search.new(RedisIndex) {
    boost weights
  }
  map 'memory_changing', Search.new(MemoryChangingIndex)
  map 'redis_changing', Search.new(RedisChangingIndex)
  map 'csv', Search.new(CSVTestIndex) {
    boost weights
  }  
  map 'isbn', Search.new(ISBNIndex)
  map 'sym', Search.new(SymKeysIndex)
  map 'geo', Search.new(RealGeoIndex)
  map 'simple_geo', Search.new(MgeoIndex)
  map 'iphone', Search.new(IphoneLocations)
  map 'indexing', Search.new(IndexingIndex)
  map 'file', Search.new(FileIndex)
  map 'japanese', Search.new(JapaneseIndex) {
    searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/
  }
  map 'nonstring', Search.new(NonstringDataIndex)
  map 'partial', Search.new(PartialIndex)
  # map 'sqlite', Search.new(SQLiteIndex) # TODO Fix, reinstate.
  map 'commas', Search.new(CommaIdsIndex)
  map 'all', Search.new(BooksIndex, CSVTestIndex, ISBNIndex, MgeoIndex) {
    boost weights
  }
end