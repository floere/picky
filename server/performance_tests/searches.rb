class Searches
  
  include Enumerable
  
  attr_reader :complexity, :data_size
  
  def initialize complexity, data_size
    @complexity, @data_size = complexity, data_size
  end
  
  def self.each data_size
    (1..5).each do |complexity|
      yield new(complexity, data_size)
    end
  end
  
  def each &block
    self.class.buffer[complexity].each &block
  end
  
  def first queries, &block
    if queries > data_size
      self.class.buffer[complexity].first(data_size).cycle(queries/data_size).each &block
    else
      self.class.buffer[complexity].first(queries).each &block
    end
  end
  
  def self.buffer
    @buffer
  end
  def self.size
    @size
  end
  
  def self.prepare 
    @buffer = {}

    @size = 0
    CSV.open('data.csv').each do |id, *args|
      @size += 1
      (1..5).each do |complexity|
        @buffer[complexity] ||= []
        @buffer[complexity] << args.first(complexity).join(' ')
      end
    end
  end

end