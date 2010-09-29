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
    illegal_characters(/[^a-zA-Z0-9\s\/\-\"\&\.äöü]/)
    stopwords(/\b(und|der|die|das|mit|im|ein|des|dem|the|of)\b/)
    split_text_on(/[\s\/\-\"\&\.]/)
    
    type :books,
         Sources::DB.new(
           'SELECT id, title, author, isbn13 as isbn FROM books',
           DB.configure(:file => 'app/db.yml')
         ),
         field(:title,  :qualifiers => [:t, :title, :titre], :similarity => Similarity::DoubleLevenshtone.new(3)),
         field(:author, :qualifiers => [:s, :author, :auteur]),
         field(:isbn,   :qualifiers => [:i, :isbn]),
         :heuristics => [
           [:title] => 6, # includes [:title, :title, ...]
           [:author, :title] => 3
         ]
  end
  
  queries do
    maximum_tokens 5
    illegal_characters(/[^a-zA-Z0-9\s\/\-\"\,\&äöü\~\*\:]/)
    stopwords(/\b(und|der|die|das|mit|ein|des|dem|the|of)\b/)
    split_text_on(/[\s\/\-\,\&]+/)
    
    route %r{^/books/full}, Query::Full.new(Indexes[:books])
    route %r{^/books/live}, Query::Live.new(Indexes[:books])
    
    root 200
  end
  
end