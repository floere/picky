class Model
  attr_reader :id, :text
  def initialize id, text
    @id, @text = id, text
  end
  def self.all
    [
      new(1, "Hi"),
      new(2, "It's"),
      new(3, "Mister"),
      new(4, "Model")
    ]
  end
end
