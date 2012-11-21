require_relative '../models/book'

ISBNIndex = Picky::Index.new :isbn do
  source { Book.all }
  category :isbn, :qualifiers => [:i, :isbn]
end