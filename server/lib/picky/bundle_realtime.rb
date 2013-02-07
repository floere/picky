module Picky

  class Bundle
    
    # TODO Make this a module to include in Memory and SQLite.
    #
    # Redis will define its own methods. Or should we build what Redis
    # is using, using a proxy which swallows up the commands from here
    # and then send it as a single command? Probably not possible.
    #
    
    # TODO Push methods back into the backend, so that we
    #      can apply more efficient methods tailored for
    #      each specific backends.
    #
    
    # Removes the given id from the indexes.
    #
    def remove id
      backend.remove id, weight_strategy, similarity_strategy
    end

    # Returns a reference to the array where the id has been added.
    #
    def add id, str_or_sym, where = :unshift
      backend.add id, str_or_sym, weight_strategy, similarity_strategy, where
    end
    
    def add_partialized id, text, where
      backend.add_partialized id, text, partial_strategy, weight_strategy, similarity_strategy, where
    end

    # Add string/symbol to similarity index.
    #
    def add_similarity str_or_sym, where = :unshift
      backend.add_similarity str_or_sym, similarity_strategy, where
    end

  end

end
