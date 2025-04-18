require_relative '../models/book'

BooksIndex = Picky::Index.new :books do
  key_format :to_i
  source   { Book.all }
  category :id
  category :title,
           qualifiers: [:t, :title, :titre],
           partial: Picky::Partial::Substring.new(from: 1),
           similarity: Picky::Similarity::DoubleMetaphone.new(2)
  category :author, partial: Picky::Partial::Substring.new(from: -2)
  category :year, qualifiers: [:y, :year, :annee]

  result_identifier 'boooookies'
end
