# encoding: utf-8
#
module Index

  # This index combines an exact and partial index.
  # It serves to order the results such that exact  hits are found first.
  #
  # TODO Need to use the right subtokens. Bake in?
  #
  # TODO One can use it as a wrapper, and it will extract the indexes itself. Rename: ExactFirst.
  #
  class Combined < Bundle
    
    delegate :similar,
             :identifier,
             :name,
             :to => :@exact
    delegate :type,
             :category,
             :weight,
             :generate_partial_from,
             :generate_caches_from_memory,
             :generate_derived,
             :dump,
             :load,
             :to => :@partial
    
    # TODO initialize type_or_category # => installs itself on all exact and partial
    #
    def initialize exact, partial
      @exact   = exact
      @partial = partial
    end
    
    def ids text
      @exact.ids(text) + @partial.ids(text)
    end
    
    def weight text
      [@exact.weight(text) || 0, @partial.weight(text) || 0].max
    end
    
  end
  
end