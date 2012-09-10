require 'csv'

# A book is simple, it has just:
#  * a title
#  * an author
#  * an isbn
#  * a publishing year
#  * a publisher
#  * a number of subjects
#
class Book
  
  @@books_mapping = {}
  
  # Load the books on startup.
  #
  file_name = File.expand_path "data/#{PICKY_ENVIRONMENT}/library.csv", File.dirname(__FILE__)
  CSV.open(file_name, 'r').each do |row|
    @@books_mapping[row.shift.to_i] = row
  end
  
  # Find uses a lookup table.
  #
  def self.find ids, _ = {}
    ids.map { |id| new(id, *@@books_mapping[id]) }
  end
  
  attr_reader :id
  
  def initialize id, title, author, year, publisher, subjects
    @id, @title, @author, @year, @publisher, @subjects = id, title, author, year, publisher, subjects
  end
  
  # "Rendering" ;)
  #
  # Note: This is just an example. Please do not render in the model.
  #
  def to_s
    "<li class='book'><h3><a href='http://google.com?q=#{@title}'>#{@title}</a></h3><em>#{@author}</em><p>#{@year}, #{@publisher}</p><p>#{@subjects}</p></li>"
  end
  
end
