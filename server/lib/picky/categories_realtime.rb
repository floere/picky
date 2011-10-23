module Picky

  class Categories

    each_delegate :remove,
                  :to => :categories

    # TODO Rewrite indexing/tokenizer/caching etc.
    #
    def add object
      id = object.id
      categories.each do |category|
        tokens, _ = category.tokenizer.tokenize object.send(category.from).to_s
        category.add id, tokens
      end
    end

    # TODO
    #
    def replace object
      remove object.id
      add object
    end

  end

end