module Picky

  class Categories

    each_delegate :remove,
                  :replace,
                  :to => :categories

    # TODO Rewrite indexing/tokenizer/caching etc.
    #
    def add object
      id = object.id
      categories.each do |category|
        tokens, _ = category.tokenizer.tokenize object.send(category.from).to_s
        category.add_tokenized id, tokens
      end
    end

  end

end