class Indexes

  #
  #
  class Base

    attr_reader :result_identifier,
                :combinator

    delegate :load_from_cache,
             :analyze,
             :reindex,
             :possible_combinations,
             :to => :categories

    alias reload load_from_cache

  end

end