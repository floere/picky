require 'csv'

class Book
  
  @@books_mapping = {}
  
  # Load the books on startup.
  #
  file_name = File.expand_path 'books.csv', File.dirname(__FILE__)
  CSV.open(file_name, 'r').each do |row|
    @@books_mapping[row.shift.to_i] = row
  end
  
  def self.find ids, _ = {}
    ids.map { |id| new(id, *@@books_mapping[id]) }
  end
  
  attr_reader :id
  
  def initialize id, title, author, isbn, year, publisher, subjects
    @id, @title, @author, @isbn, @year, @publisher, @subjects = id, title, author, isbn, year, publisher, subjects
  end
  
  # "Rendering" ;)
  #
  def to_s
    "<div class='book'><p>\"#{@title}\", by #{@author}</p><p>#{@year}, #{@publisher}, #{@isbn}</p><p>#{@subjects}</p></div>"
  end
  
end