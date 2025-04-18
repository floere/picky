require_relative '../models/book'

ISBNIndex = Picky::Index.new :isbn do
  key_format :to_i
  source { Book.all }
  category :isbn, qualifiers: [:i, :isbn]
end