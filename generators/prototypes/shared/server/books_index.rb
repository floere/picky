# encoding: utf-8
#

# Data source.
#
class Books

  def initialize
    @csv = CSV.new File.open(File.expand_path("../data/#{PICKY_ENVIRONMENT}/library.csv", __FILE__))
  end

  def each
    instance = Struct.new :id, :title, :author, :year
    @csv.each do |row|
      yield instance.new *row[0..3]
    end
  end

end

# Define an index.
#
BooksIndex = Picky::Index.new :books do
  key_format :to_i
  
  source { Books.new }
  indexing removes_characters: /[^a-z0-9\s\/\-\_\:\"\&\.]/i,
           stopwords:          /\b(and|the|of|it|in|for)\b/i,
           splits_text_on:     /[\s\/\-\_\:\"\&\.]/
  category :title,
           similarity: Picky::Similarity::DoubleMetaphone.new(3),
           partial: Picky::Partial::Substring.new(from: 1) # Default is from: -3.
  category :author, partial: Picky::Partial::Substring.new(from: 1)
  category :year, partial: Picky::Partial::None.new
end

# Index and load on USR1 signal.
#
Signal.trap('USR1') do
  BooksIndex.reindex # kill -USR1 <pid>
end