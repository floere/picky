# encoding: utf-8
#

BookSearch.instance_eval do
  
  weights = {
    [:author]         => +6,
    [:title, :author] => +5,
    [:author, :year]  => +2
  }

  map 'books', Picky::Search.new(BooksIndex, ISBNIndex) {
    boost weights
  }
  map 'books_ignoring', Picky::Search.new(BooksIndex, ISBNIndex) {
    boost weights
    ignore_unassigned_tokens true
  }
  map 'book_each', Picky::Search.new(BookEachIndex) {
    boost weights
    # ignore :title
  }
  map 'redis', Picky::Search.new(RedisIndex) {
    boost weights
  }
  map 'memory_changing', Picky::Search.new(MemoryChangingIndex)
  map 'redis_changing', Picky::Search.new(RedisChangingIndex)
  map 'csv', Picky::Search.new(CSVTestIndex) {
    boost weights
  }  
  map 'isbn', Picky::Search.new(ISBNIndex)
  map 'sym', Picky::Search.new(SymKeysIndex)
  map 'geo', Picky::Search.new(RealGeoIndex)
  map 'simple_geo', Picky::Search.new(MgeoIndex)
  map 'iphone', Picky::Search.new(IphoneLocations)
  map 'indexing', Picky::Search.new(IndexingIndex)
  map 'file', Picky::Search.new(FileIndex)
  map 'japanese', Picky::Search.new(JapaneseIndex) {
    searching removes_characters: /[^\p{Han}\p{Katakana}\p{Hiragana}\"\~\*\:\,]/i, # a-zA-Z0-9\s\/\-\_\&\.
              stopwords:          /\b(and|the|of|it|in|for)\b/i,
              splits_text_on:     /[\s\/\-\&]+/
  }
  map 'nonstring', Picky::Search.new(NonstringDataIndex)
  map 'partial', Picky::Search.new(PartialIndex)
  # map 'sqlite', Picky::Search.new(SQLiteIndex) # TODO Fix, reinstate.
  map 'commas', Picky::Search.new(CommaIdsIndex)
  map 'all', Picky::Search.new(BooksIndex, CSVTestIndex, ISBNIndex, MgeoIndex) {
    boost weights
  }
  
end