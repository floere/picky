module Picky

  class Categories

    attr_reader :categories, :category_hash

    delegate :each,
             :first,
             :map,
             :to => :categories

    each_delegate :reindex,
                  :dump,
                  :each_category,
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

    # Add the given category to the list of categories.
    #
    def << category
      categories << category
      category_hash[category.name] = category
    end

    # Find a given category in the categories.
    #
    def [] category_name
      category_name = category_name.to_sym
      category_hash[category_name] || raise_not_found(category_name)
    end
    def raise_not_found category_name
      raise %Q{Index category "#{category_name}" not found. Possible categories: "#{categories.map(&:name).join('", "')}".}
    end

    def to_s
      categories.join(', ')
    end

  end

end