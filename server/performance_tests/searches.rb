class Searches
  
  include Enumerable
  
  def self.series_for amount
    (1..5).map { |i| new i, amount }
  end

  def initialize complexity, amount
    @complexity, @amount = complexity, amount
  end

  def each &block
    @buffer.each &block
  end

  def prepare
    @buffer = []

    i = 0
    CSV.open('data.csv').each do |args|
      _, *args = args
      args = args + [args.first]
      query = []
      (@complexity-1).times do
        query << args.shift
      end
      query << args.shift
      @buffer << query.join(' ')
      break if (i+=1) == @amount
    end
  end

end