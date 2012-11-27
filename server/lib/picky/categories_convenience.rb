module Picky

  #
  #
  class Categories

    each_forward :each_bundle, :to => :categories

    def each_category &block
      categories.each &block
    end
  end

end