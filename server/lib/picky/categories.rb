class Categories

  attr_reader :categories, :category_hash

  delegate :each,
           :first,
           :map,
           :to => :categories

  each_delegate :reindex,
                :to => :categories

  # A list of indexed categories.
  #
  # Options:
  #  * ignore_unassigned_tokens: Ignore the given token if it cannot be matched to a category.
  #                              The default behaviour is that if a token does not match to
  #                              any category, the query will not return anything (since a
  #                              single token cannot be matched). If you set this option to
  #                              true, any token that cannot be matched to a category will be
  #                              simply ignored.
  #                              Use this if only a few matched words are important, like for
  #                              example of the query "Jonathan Myers 86455 Las Cucarachas"
  #                              you only want to match the zipcode, to have the search engine
  #                              display advertisements on the side for the zipcode.
  #                              Nifty! :)
  #
  def initialize options = {}
    clear

    @ignore_unassigned_tokens = options[:ignore_unassigned_tokens] || false
  end

  # Clears both the array of categories and the hash of categories.
  #
  def clear
    @categories    = []
    @category_hash = {}
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

  # Add the given category to the list of categories.
  #
  def << category
    categories << category
    category_hash[category.name] = category
  end

  def to_s
    categories.join(', ')
  end

end