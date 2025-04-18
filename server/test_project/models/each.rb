class Each
  def self.all(file, options = {})
    Yielder.new file, accessibility, options
  end

  def self.accessibility
    const_get :Accessibility
  end

  class Yielder
    def initialize(file, accessibility, options)
      @file = file
      @accessibility = accessibility
      @options = options
    end

    def each
      CSV.foreach(@file, @options) do |row|
        yield row.extend @accessibility
      end
    end
  end
end
