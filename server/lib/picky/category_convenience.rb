module Picky

  class Category

    def each_bundle &block
      if block
        yield exact
        yield partial
      else
        [exact, partial]
      end
    end

  end

end