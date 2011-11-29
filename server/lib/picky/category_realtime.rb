module Picky

  class Category

    # Removes an indexed object with the
    # given id.
    #
    def remove id
      id = id.send key_format
      exact.remove id
      partial.remove id
    end

    # Adds and indexes this category of the
    # given object.
    #
    def add object, where = :unshift
      tokens, _ = tokenizer.tokenize object.send(from)
      add_tokenized object.id, tokens, where
    end

    # Removes the object's id, and then
    # adds it again.
    #
    def replace object, where = :unshift
      remove object.id
      add object, where
    end

    # Add at the end.
    #
    def << thing
      add thing, __method__
    end

    # Add at the beginning.
    #
    def unshift thing
      add thing, __method__
    end

    # For the given id, adds the list of
    # strings to the index for the given id.
    #
    def add_tokenized id, tokens, where = :unshift
      tokens.each { |text| add_tokenized_token id, text, where }
    end

    #
    #
    def add_tokenized_token id, text, where = :unshift
      return unless text
      id = id.send key_format # TODO Speed this up!

      # text = text.to_sym if @symbols # TODO Symbols.
      exact.add id, text, where
      partial.add_partialized id, text, where
    end

    # Clears the realtime mapping.
    #
    def clear_realtime
      exact.clear_realtime
      partial.clear_realtime
    end

    # Builds the realtime mapping.
    #
    def build_realtime_mapping
      exact.build_realtime
      partial.build_realtime
    end

  end

end