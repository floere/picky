module Picky

  class Category

    # Removes an indexed object with the
    # given id.
    #
    def remove id
      indexed_exact.remove id
      indexed_partial.remove id
    end

    # Adds and indexes this category of the
    # given object.
    #
    def add object
      tokens, _ = tokenizer.tokenize object.send(from).to_s
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
        indexed_exact.add id, text

        # TODO Refactor. Push into indexed_partial?
        #
        indexed_partial.partial_strategy.each_partial text do |partial_text|
          indexed_partial.add id, partial_text
        end
      end
    end

  end

end