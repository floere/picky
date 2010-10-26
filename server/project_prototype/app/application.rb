# encoding: utf-8
#
class PickySearch < Application
  
  # TODO Adapt the generated example
  #      (a library books finder) to what you need.
  #
  # Check the Wiki http://github.com/floere/picky/wiki for more options.
  #
  # Ask me or the google group if you have questions or specific requests.
  #
  
  indexing.removes_characters(/[^a-zA-Z0-9\s\/\-\"\&\.]/)
  indexing.stopwords(/\b(and|the|of|it|in|for)\b/)
  indexing.splits_text_on(/[\s\/\-\"\&\.]/)
      
  books_index = index :books,
                      Sources::CSV.new(:title, :author, :isbn, :year, :publisher, :subjects, :file => 'app/library.csv'),
                      # Use a database as source:
                      # Sources::DB.new('SELECT id, title, author, isbn13 as isbn FROM books', :file => 'app/db.yml'),
                      # Or delicious:
                      # Sources::Delicious.new('username', 'password'), # offers title, tags, url fields.
                      field(:title,
                            :partial => Partial::Substring.new(:from => 1), # Index substrings upwards from character 1 (default: -3),
                                                                              # e.g. picky -> p, pi, pic, pick, picky
                                                                              # Like this, you'll find picky even when entering just a "p".
                            :similarity => Similarity::DoubleLevenshtone.new(3)), # Up to three similar title word indexed (default: no similarity).
                      field(:author, :partial => Partial::Substring.new(:from => 1)),
                      field(:isbn,   :partial => Partial::None.new) # Partial substring searching on an ISBN makes not much sense, neither does similarity.
  
  # Defines the maximum tokens (words) that pass through to the engine.
  #
  querying.maximum_tokens 5
  
  # Note that Picky needs the following characters to
  # pass through, as they are control characters: *"~:
  #
  querying.removes_characters(/[^a-zA-Z0-9\s\/\-\,\&\"\~\*\:]/)
  querying.stopwords(/\b(and|the|of|it|in|for)\b/)
  querying.splits_text_on(/[\s\/\-\,\&]+/)
  
  # The example defines two queries that use the same index(es).
  #
  # A Full query returns ids, combinations, and counts.
  # A Live query does return all that Full returns, without ids.
  #
  # Note: You can pass a query multiple indexes and it will combine them.
  #
  full_books = Query::Full.new books_index
  live_books = Query::Live.new books_index
  
  # Routing is simple.
  # A path regexp pointing to a query that will be run.
  #
  route %r{^/books/full} => full_books
  route %r{^/books/live} => live_books
  
end