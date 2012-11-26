module Picky

  class Categories

    attr_reader :categories, :category_hash

    delegate :each,
             :first,
             :map,
             :to => :categories

    each_delegate :cache,
                  :dump,
                  :empty,
                  :inject,
                  :reindex,
                  :reset_backend,
                  :to => :categories

    # A list of indexed categories.
    #
    def initialize options = {}
      clear_categories
    end

    # Clears both the array of categories and the hash of categories.
    #
    def clear_categories
      @categories    = []
      @category_hash = {}
    end
    
    # Updates the qualifier ("qualifier:searchterm") mapping.
    #
    # Example:
    #   You dynamically add a new category to an index.
    #   To add the qualifiers to a search, you call this
    #   method.
    #
    def mapper
      @mapper ||= QualifierMapper.new self
    end

    # Add the given category to the list of categories.
    #
    def << category
      @mapper = nil # TODO Move. (Resets category mapping)
      categories << category
      category_hash[category.name] = category
    end

    # Find a given category in the categories.
    #
    def [] category_name
      category_name = category_name.intern
      category_hash[category_name] || raise_not_found(category_name)
    end
    def raise_not_found category_name
      raise %Q{Index category "#{category_name}" not found. Possible categories: "#{categories.map(&:name).join('", "')}".}
    end
    
    def to_stats
      map(&:name).join(', ')
    end

    def to_s
      "#{self.class}(#{categories.join(', ')})"
    end

  end

end