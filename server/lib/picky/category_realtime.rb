module Picky

  class Category

    # Removes an indexed object with the
    # given id.
    #
    def remove id
      exact.remove id
      partial.remove id
    end

    # Adds and indexes this category of the
    # given object.
    #
    def add object
      tokens, _ = tokenizer.tokenize object.send(from)
      add_tokenized object.id, tokens
    end

    # Removes the object's id, and then
    # adds it again.
    #
    def replace object
      remove object.id
      add object
    end

    # For the given id, adds the list of
    # strings to the index for the given id.
    #
    def add_tokenized id, tokens
      tokens.each do |text|
        next unless text
        text = text.to_sym
        exact.add id, text
        partial.add_partialized id, text
      end
    end

  end

end