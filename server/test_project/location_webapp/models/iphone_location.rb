require 'csv'

class IphoneLocation

  @@location_mapping = {}

  # Load the books on startup.
  #
  file_name = File.expand_path '../../data/iphone_locations.csv', File.dirname(__FILE__)
  CSV.open(file_name, 'r').each do |row|
    @@location_mapping[row.shift.to_i] = row
  end

  # Find uses a lookup table.
  #
  def self.find ids, _ = {}
    ids.map { |id| new(id, *@@location_mapping[id]) }
  end

  attr_reader :id, :timestamp, :north, :east

  def initialize id, _, _, _, _, timestamp, north, east, *args
    @id, @timestamp, @north, @east = id, timestamp, north, east
  end

  # "Rendering" ;)
  #
  # Note: This is just an example. Please do not render in the model.
  #
  def to_s
    "<div class='book'><p>\"#{@timestamp}\" (#{@north}, #{@east})</p></div>"
  end

end