module Picky

  #
  #
  class Index

    attr_reader :combinator

    delegate :load_from_cache,
             :analyze,
             :reindex,
             :possible_combinations,
             :to => :categories

    alias reload load_from_cache

    # Define how the results of this index are identified.
    # (Shown in the client, for example)
    #
    # Default is the name of the index.
    #
    def result_identifier result_identifier = nil
      result_identifier ? define_result_identifier(result_identifier) : (@result_identifier || @name)
    end
    def define_result_identifier result_identifier
      @result_identifier = result_identifier
    end

  end

end