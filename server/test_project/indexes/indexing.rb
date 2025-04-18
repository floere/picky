# encoding: utf-8
#
IndexingIndex = Picky::Index.new(:special_indexing) do
  key_format :to_i
  source   { CSVBook.all('data/books.csv') }
  indexing removes_characters: /[^äöüd-zD-Z0-9\s\/\-"&.]/i, # a-c, A-C are removed
           splits_text_on:     /[\s\/\-"&\/]/
  category :title,
           qualifiers: [:t, :title, :titre],
           partial:    Picky::Partial::Substring.new(from: 1),
           similarity: Picky::Similarity::DoubleMetaphone.new(2)
end