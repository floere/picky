# This class defines the indexing and index API that is exposed to the user.
# It provides a single front for both indexing and index options.
#
# Note: An Index holds both an *Indexed*::*Index* and an *Indexing*::*Type*.
#
class IndexAPI # :nodoc:all
  
  attr_reader :name, :indexing, :indexed
  
  # TODO Doc.
  #
  def initialize name, source, options = {}
    @name     = name
    @indexing = Indexing::Index.new name, source, options
    @indexed  = Indexed::Index.new  name, options
    
    # Centralized registry.
    #
    Indexes.register self
  end
  
  # Parameters:
  # category_name: This identifier is used in the front end, but also to categorize query text. For example, “title:hobbit” will narrow the hobbit query on categories with the identifier :title.
  #
  # Options:
  # * partial: Partial::None.new or Partial::Substring.new(from: starting_char, to: ending_char). Default is Partial::Substring.new(from: -3, to: -1).
  # * similarity: Similarity::None.new or Similarity::Phonetic.new(similar_words_searched). Default is Similarity::None.new.
  # * qualifiers: An array of qualifiers with which you can define which category you’d like to search, for example “title:hobbit” will search for hobbit in just title categories. Example: qualifiers: [:t, :titre, :title] (use it for example with multiple languages). Default is the name of the category.
  # * qualifier: Convenience options if you just need a single qualifier, see above. Example: qualifiers => :title. Default is the name of the category.
  # * source: Use a different source than the index uses. If you think you need that, there might be a better solution to your problem. Please post to the mailing list first with your application.rb :)
  # * from: Take the data from the data category with this name. Example: You have a source Sources::CSV.new(:title, file:'some_file.csv') but you want the category to be called differently. The you use from: define_category(:similar_title, :from => :title).
  #
  def define_category category_name, options = {}
    category_name = category_name.to_sym
    
    indexing_category = indexing.define_category category_name, options
    indexed_category  = indexed.define_category  category_name, options
    
    yield indexing_category, indexed_category if block_given?
    
    self
  end
  alias category define_category
  
  # Parameters:
  # * name: The name as used in #define_category.
  # * radius: The range (in km) around the query point which we search for results.
  #
  #        <---range---|
  #  -----|------------*------------|-----
  #
  # Options
  # * precision # Default 1 (20% error margin, very fast), up to 5 (5% error margin, slower) makes sense.
  # * from: # The data category to take the data for this category from.
  #
  def define_location name, range, options = {}
    precision = options[:precision]
    
    options = { partial: Partial::None.new }.merge options
    
    define_category name, options do |indexing, indexed|
      indexing.source    = Sources::Wrappers::Location.new indexing, grid: range, precision: precision
      indexing.tokenizer = Tokenizers::Index.new
      
      exact_bundle    = Indexed::Wrappers::Bundle::Location.new indexed.exact, grid: range, precision: precision
      indexed.exact   = exact_bundle
      indexed.partial = exact_bundle # A partial token also uses the exact index.
    end
  end
  alias location define_location
  
  # Parameters:
  # * name: The name as used in #define_category.
  # * radius: The distance (in km) around the query point which we search for results.
  #
  # Note: Picky uses a square, not a circle.
  #
  #  -----------------------------
  #  |                           |
  #  |                           |
  #  |                           |
  #  |                           |
  #  |                           |
  #  |             *<-  radius ->|
  #  |                           |
  #  |                           |
  #  |                           |
  #  |                           |
  #  |                           |
  #  -----------------------------
  #
  # Options
  # * precision: Default 1 (20% error margin, very fast), up to 5 (5% error margin, slower) makes sense.
  # * from: The data category to take the data for this category from.
  #
  def define_map_location name, radius, options = {}
    # The radius is given as if all the locations were on the equator.
    #
    # TODO Need to recalculate since not many locations are on the equator ;) This is just a prototype.
    #
    # This calculates km -> longitude (degrees).
    #
    # A degree on the equator is equal to ~111,319.9 meters.
    # So a km on the equator is equal to 0.00898312 degrees.
    #
    define_location name, radius * 0.00898312, options
  end
end