module Index

  # This class defines the indexing and index API that is exposed to the user
  # as the #index method inside the Application class.
  #
  # It provides a single front for both indexing and index options. We suggest to always use the index API.
  #
  # Note: An Index holds both an *Indexed*::*Index* and an *Indexing*::*Type*.
  #
  class Base

    attr_reader :name, :indexing, :indexed

    # Create a new index with a given source.
    #
    # === Parameters
    # * name: A name that will be used for the index directory and in the Picky front end.
    # * source: Where the data comes from, e.g. Sources::CSV.new(...)
    #
    # === Options
    # * result_identifier: Use if you'd like a different identifier/name in the results than the name of the index.
    # * after_indexing: As of this writing only used in the db source. Executes the given after_indexing as SQL after the indexing process.
    #
    def initialize name, source, options = {}
      check name, source

      @name     = name.to_sym
      @indexing = Internals::Indexing::Index.new name, source, options
      @indexed  = Internals::Indexed::Index.new  name, options

      # Centralized registry.
      #
      Indexes.register self
    end
    #
    # Since this is an API, we fail hard quickly.
    #
    def check name, source
      raise ArgumentError.new(<<-NAME
The index identifier (you gave "#{name}") for Index::Memory/Index::Redis should be a String/Symbol,
Examples:
  Index::Memory.new(:my_cool_index, ...) # Recommended
  Index::Redis.new("a-redis-index", ...)
NAME
) unless name.respond_to?(:to_sym)
      raise ArgumentError.new(<<-SOURCE
The index "#{name}" should use a data source that responds to the method #harvest, which yields(id, text).
Or it could use one of the built-in sources:
  Sources::#{(Sources.constants - [:Base, :Wrappers, :NoCSVFileGiven, :NoCouchDBGiven]).join(',
  Sources::')}
SOURCE
) unless source.respond_to?(:harvest)
    end

    def to_stats
      stats = <<-INDEX
#{name} (#{self.class}):
  #{"source:            #{indexing.source}".indented_to_s}
  #{"categories:        #{indexing.categories.categories.map(&:name).join(', ')}".indented_to_s}
INDEX
      stats << "  result identifier: \"#{indexed.result_identifier}\"".indented_to_s unless indexed.result_identifier.to_s == indexed.name.to_s
      stats
    end

    # Defines a searchable category on the index.
    #
    # === Parameters
    # * category_name: This identifier is used in the front end, but also to categorize query text. For example, “title:hobbit” will narrow the hobbit query on categories with the identifier :title.
    #
    # === Options
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

    #  HIGHLY EXPERIMENTAL Try if you feel "beta" ;)
    #
    # Make this category range searchable with a fixed range. If you need other ranges, define another category with a different range value.
    #
    # Example:
    # You have data values inside 1..100, and you want to have Picky return
    # not only the results for 47 if you search for 47, but also results for
    # 45, 46, or 47.2, 48.9, in a range of 2 around 47, so (45..49).
    #
    # Then you use:
    #  my_index.define_ranged_category :values_inside_1_100, 2
    #
    # Optionally, you give it a precision value to reduce the error margin
    # around 47 (Picky is a bit liberal).
    #  my_index.define_ranged_category :values_inside_1_100, 2, precision: 5
    #
    # This will force Picky to maximally be wrong 5% of the given range value
    # (5% of 2 = 0.1) instead of the default 20% (20% of 2 = 0.4).
    #
    # We suggest not to use much more than 5 as a higher precision is more performance intensive for less and less precision gain.
    #
    # == Protip 1
    #
    # Create two ranged categories to make an area search:
    #   index.define_ranged_category :x, 1
    #   index.define_ranged_category :y, 1
    #
    # Search for it using for example:
    #   x:133, y:120
    #
    # This will search this square area (* = 133, 120: The "search" point entered):
    #
    #    132       134
    #     |         |
    #   --|---------|-- 121
    #     |         |
    #     |    *    |
    #     |         |
    #   --|---------|-- 119
    #     |         |
    #
    # Note: The area does not need to be square, but can be rectangular.
    #
    # == Protip 2
    #
    # Create three ranged categories to make a volume search.
    #
    # Or go crazy and use 4 ranged categories for a space/time search! ;)
    #
    # === Parameters
    # * category_name: The category_name as used in #define_category.
    # * range: The range (in the units of your data values) around the query point where we search for results.
    #
    #  -----|<- range  ->*------------|-----
    #
    # === Options
    # * precision: Default is 1 (20% error margin, very fast), up to 5 (5% error margin, slower) makes sense.
    # * ... all options of #define_category.
    #
    def define_ranged_category category_name, range, options = {}
      precision = options[:precision]

      options = { partial: Partial::None.new }.merge options

      define_category category_name, options do |indexing, indexed|
        indexing.source    = Sources::Wrappers::Location.new indexing, grid: range, precision: precision
        indexing.tokenizer = Internals::Tokenizers::Index.new

        exact_bundle    = Indexed::Wrappers::Bundle::Location.new indexed.exact, grid: range, precision: precision
        indexed.exact   = exact_bundle
        indexed.partial = exact_bundle # A partial token also uses the exact index.
      end
    end
    alias ranged_category define_ranged_category

    #  HIGHLY EXPERIMENTAL Not correctly working yet. Try it if you feel "beta".
    #
    # Also a range search see #define_ranged_category, but on the earth's surface.
    #
    # Parameters:
    # * name: The name as used in #define_category.
    # * radius: The distance (in km) around the query point which we search for results.
    #
    # Note: Picky uses a square, not a circle. We hope that's ok for most usages.
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
    # TODO Redo. Will have to write a wrapper that combines two categories that are indexed simultaneously.
    #
    def define_map_location name, radius, options = {} # :nodoc:
      # The radius is given as if all the locations were on the equator.
      #
      # TODO Need to recalculate since not many locations are on the equator ;) This is just a prototype.
      #
      # This calculates km -> longitude (degrees).
      #
      # A degree on the equator is equal to ~111,319.9 meters.
      # So a km on the equator is equal to 0.00898312 degrees.
      #
      define_ranged_category name, radius * 0.00898312, options
    end
    alias map_location define_map_location
  end

end