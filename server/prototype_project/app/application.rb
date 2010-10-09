# encoding: utf-8
#
# This is your application.
#
# Have fun with Picky!
#
class PickySearch < Application # The App Constant needs to be identical in application.ru.
  
  # This is an example with books that you can adapt.
  #
  # Note: Much more is possible, but let's start out super easy.
  #
  # Ask me if you have questions or specific requests!
  #
  
  indexes do
    illegal_characters(/[^a-zA-Z0-9\s\/\-\"\&\.]/)
    stopwords(/\b(and|the|of|it|in|for)\b/)
    split_text_on(/[\s\/\-\"\&\.]/)
      
    add_index :books,
              Sources::DB.new('SELECT id, title, author, isbn13 as isbn FROM books', :file => 'app/db.yml'),
              field(:title, :similarity => Similarity::DoubleLevenshtone.new(3)), # Up to three similar title word indexed.
              field(:author),
              field(:isbn,  :partial => Partial::None.new) # Partially searching on an ISBN makes not much sense.
  end
  
  queries do
    maximum_tokens 5
    # Note that Picky needs the following characters to
    # pass through, as they are control characters: *"~:
    #
    illegal_characters(/[^a-zA-Z0-9\s\/\-\,\&\"\~\*\:]/)
    stopwords(/\b(and|the|of|it|in|for)\b/)
    split_text_on(/[\s\/\-\,\&]+/)
    
    # The example defines two queries that use the same index(es).
    #
    # A Full query returns ids, combinations, and counts.
    # A Live query does return all that Full returns, without ids.
    #
    route %r{^/books/full}, Query::Full.new(Indexes[:books])
    route %r{^/books/live}, Query::Live.new(Indexes[:books])
  end
  
end