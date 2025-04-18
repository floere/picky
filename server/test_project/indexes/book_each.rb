require_relative '../models/book'
BookEachIndex = Picky::Index.new :book_each do
  key_format :to_s
  source     { Book.order('title ASC') }
  category   :id
  category   :title,
             qualifiers: [:t, :title, :titre],
             partial: Picky::Partial::Substring.new(from: 1),
             similarity: Picky::Similarity::DoubleMetaphone.new(2)
  category   :author, partial: Picky::Partial::Substring.new(from: -2)
  category   :year, qualifiers: [:y, :year, :annee]
end
