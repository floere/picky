# encoding: utf-8
#
# This is your application.
#
# Have fun with Picky!
#
class PickySearch < Application # The App Constant needs to be identical in application.ru.
  
  # This is an example with books that you can adapt.
  #
  # Note: Much more is possible, but let's start out easy.
  #
  # Ask me if you have questions!
  #  
  
  indexes do
    illegal_characters(/[^äöüa-zA-Z0-9\s\/\-\"\&\.]/)
    stopwords(/\b(und|der|die|das|mit|im|ein|des|dem|the|of)\b/)
    split_text_on(/[\s\/\-\"\&\.]/)
      
    type :books,
         Sources::DB.new(
           'SELECT id, title, author, isbn13 as isbn FROM books',
           DB.configured(:file => 'app/db.yml')
         ),
         field(:title,  :qualifiers => [:t, :title, :titre], :similarity => Similarity::DoubleLevenshtone.new(3)), # Up to three similar title word indexed.
         field(:author, :qualifiers => [:s, :author, :auteur]),
         field(:isbn,   :qualifiers => [:i, :isbn],          :partial => Partial::None.new) # Partially searching on an ISBN makes not much sense.
  end
  
  queries do
    maximum_tokens 5
    # Note that Picky needs the following characters to
    # pass through, as they are control characters: *"~:
    #
    illegal_characters(/[^a-zA-Z0-9\s\/\-\,\&äöü\"\~\*\:]/)
    stopwords(/\b(und|der|die|das|mit|ein|des|dem|the|of)\b/)
    split_text_on(/[\s\/\-\,\&]+/)
    
    # Set some weights according to the position. Note that the order is important.
    #
    options = { :weights => Query::Weights.new([:title] => 6, [:author, :title] => 3) }
    
    route %r{^/books/full}, Query::Full.new(Indexes[:books], options)
    route %r{^/books/live}, Query::Live.new(Indexes[:books], options)
    
    root 200
  end
  
end