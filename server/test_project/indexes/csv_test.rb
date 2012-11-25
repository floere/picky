require_relative '../models/csv_book'
CSVTestIndex = Picky::Index.new :csv_test do
  source   { CSVBook.all('data/books.csv') }

  category :title,
           qualifiers: [:t, :title, :titre],
           partial:    Picky::Partial::Substring.new(from: 1),
           similarity: Picky::Similarity::DoubleMetaphone.new(2)
  category :author,
           qualifiers: [:a, :author, :auteur],
           partial:    Picky::Partial::Substring.new(from: -2)
  category :year,
           qualifiers: [:y, :year, :annee],
           partial:    Picky::Partial::None.new
  category :publisher, qualifiers: [:p, :publisher]
  category :subjects, qualifiers: [:s, :subject]

  result_identifier :Books
end