class Source

  attr_reader :amount

  def initialize(amount)
    @amount = amount
  end

  Thing = Struct.new :id, :text1, :text2, :text3, :text4, :text5

end