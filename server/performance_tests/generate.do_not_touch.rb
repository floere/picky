class IndexGenerator
  attr_reader :amount, :length

  def initialize(amount, &length)
    @random = Random.new 115032730400174366788466674494640623225
    @amount = amount
    @length = length || ->() { @random.rand(18) + 3 }
  end

  class Thing
    attr_reader :id, :text1, :text2, :text3, :text4, :text5

    def initialize(id, text1, text2, text3, text4, text5)
      @id, @text1, @text2, @text3, @text4, @text5 = id, text1, text2, text3, text4, text5
    end

    def to_s
      [id, text1, text2, text3, text4, text5].join(',')
    end
  end

  def each()
    characters = %w[a b c d]
    size = characters.size

    amount.times do |i|
      args = [i+1]
      5.times do
        current = []
        length[].times do
          current << characters[@random.rand(size)]
        end
        args << current.join
      end
      yield args
    end
  end
end

generator = IndexGenerator.new 100_000

File.open('data.csv', 'w') do |file|
  generator.each do |things|
    p things
    file.write things.join(',')
    file.write "\n"
  end
end