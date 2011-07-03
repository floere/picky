module Shared
  
  # Shared methods for
  #  * Internals::Indexed::Categories
  #  * Internals::Indexing::Categories
  #
  module Categories
    
    attr_reader :categories, :category_hash
    
    delegate :each,
             :first,
             :map,
             :to => :categories

    def to_s
      categories.indented_to_s
    end

    # Clears both the array of categories and the hash of categories.
    #
    def clear
      @categories    = []
      @category_hash = {}
    end
    
    def [] category_name
      category_hash[category_name] || raise_not_found(category_name)
    end
    def raise_not_found category_name
      raise %Q{Index category "#{category_name}" not found. Possible categories: "#{categories.map(&:name).join('", "')}".}
    end

    # Add the given category to the list of categories.
    #
    def << category
      categories << category
      category_hash[category.name] = category
    end
    
    def find category_name
      category_name = category_name.to_sym

      categories.each do |category|
        next unless category.name == category_name
        return category
      end

      raise %Q{Index category "#{category_name}" not found. Possible categories: "#{categories.map(&:name).join('", "')}".}
    end
    
  end
  
end