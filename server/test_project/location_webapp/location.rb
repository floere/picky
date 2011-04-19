require 'csv'

# A book is simple, it has just:
#  * a title
#  * an author
#  * an isbn
#  * a publishing year
#  * a publisher
#  * a number of subjects
#
class Location

  @@location_mapping = {}

  # Load the books on startup.
  #
  file_name = File.expand_path '../data/ch.csv', File.dirname(__FILE__)
  CSV.open(file_name, 'r').each do |row|
    @@location_mapping[row.shift.to_i] = row
  end

  # Find uses a lookup table.
  #
  def self.find ids, _ = {}
    ids.map { |id| new(id, *@@location_mapping[id]) }
  end

  attr_reader :id, :north, :east

  def initialize id, name, north, east
    @id, @name, @north, @east = id, name, north, east
  end

  # "Rendering" ;)
  #
  # Note: This is just an example. Please do not render in the model.
  #
  def to_s
    "<div class='book'><p>\"#{@name}\" (#{@north}, #{@east})</p></div>"
  end

end