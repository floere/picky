module Index

  # This class defines the indexing and index API that is exposed to the user
  # as the #index method inside the Application class.
  #
  # It provides a single front for both indexing and index options. We suggest to always use the index API.
  #
  # Note: An Index holds both an *Indexed*::*Index* and an *Indexing*::*Type*.
  #
  class Base

    attr_reader :name

    # Create a new index with a given source.
    #
    # === Parameters
    # * name: A name that will be used for the index directory and in the Picky front end.
    #
    # === Options
    # * source: Where the data comes from, e.g. Sources::CSV.new(...). Optional, can be defined in the block using #source.
    # * result_identifier: Use if you'd like a different identifier/name in the results than the name of the index.
    # * after_indexing: As of this writing only used in the db source. Executes the given after_indexing as SQL after the indexing process.
    # * tokenizer: The tokenizer to use for this index. Optional, can be defined in the block using #indexing.
    #
    # Examples:
    #   my_index = Index::Memory.new(:my_index, source: some_source) do
    #     category :bla
    #   end
    #
    #   my_index = Index::Memory.new(:my_index) do
    #     source   Sources::CSV.new(file: 'data/index.csv')
    #     category :bla
    #   end
    #
    #
    def initialize name, options = {}
      check_name name
      @name = name.to_sym

      check_options options
      @indexing = Internals::Indexing::Index.new name, options
      @indexed  = Internals::Indexed::Index.new  name, options

      # Centralized registry.
      #
      Indexes.register self

      #
      #
      instance_eval(&Proc.new) if block_given?

      check_source internal_indexing.source
    end
    def internal_indexing
      @indexing
    end
    def internal_indexed
      @indexed
    end
    #
    # Since this is an API, we fail hard quickly.
    #
    def check_name name
      raise ArgumentError.new(<<-NAME


The index identifier (you gave "#{name}") for Index::Memory/Index::Redis should be a Symbol/String,
Examples:
  Index::Memory.new(:my_cool_index) # Recommended
  Index::Redis.new("a-redis-index")
NAME


) unless name.respond_to?(:to_sym)
    end
    def check_options options
      raise ArgumentError.new(<<-OPTIONS


Sources are not passed in as second parameter for #{self.class.name} anymore, but either
* as :source option:
  #{self.class.name}.new(#{name.inspect}, source: #{options})
or
* given to the #source method inside the config block:
  #{self.class.name}.new(#{name.inspect}) do
    source #{options}
  end

Sorry about that breaking change (in 2.2.0), didn't want to go to 3.0.0 yet!

All the best
  -- Picky


OPTIONS
) unless options.respond_to?(:[])
    end
    def check_source source
      raise ArgumentError.new(<<-SOURCE


The index "#{name}" should use a data source that responds to either the method #each, or the method #harvest, which yields(id, text).
Or it could use one of the built-in sources:
  Sources::#{(Sources.constants - [:Base, :Wrappers, :NoCSVFileGiven, :NoCouchDBGiven]).join(',
  Sources::')}


SOURCE
) unless source.respond_to?(:each) || source.respond_to?(:harvest)
    end

    def to_stats
      stats = <<-INDEX
#{name} (#{self.class}):
  #{"source:            #{internal_indexing.source}".indented_to_s}
  #{"categories:        #{internal_indexing.categories.map(&:name).join(', ')}".indented_to_s}
INDEX
      stats << "  result identifier: \"#{internal_indexed.result_identifier}\"".indented_to_s unless internal_indexed.result_identifier.to_s == internal_indexed.name.to_s
      stats
    end

    # Define an index tokenizer on the index.
    #
    # Parameters are the exact same as for indexing.
    #
    def indexing options = {}
      internal_indexing.define_indexing options
    end
    alias define_indexing indexing

    # Define a source on the index.
    #
    # Parameter is a source, either one of the standard sources or
    # anything responding to #each and returning objects that
    # respond to id and the category names (or the category from option).
    #
    def source source
      internal_indexing.define_source source
    end
    alias define_source source

    # Defines a searchable category on the index.
    #
    # === Parameters
    # * category_name: This identifier is used in the front end, but also to categorize query text. For example, “title:hobbit” will narrow the hobbit query on categories with the identifier :title.
    #
    # === Options
    # * partial: Partial::None.new or Partial::Substring.new(from: starting_char, to: ending_char). Default is Partial::Substring.new(from: -3, to: -1).
    # * similarity: Similarity::None.new or Similarity::DoubleMetaphone.new(similar_words_searched). Default is Similarity::None.new.
    # * qualifiers: An array of qualifiers with which you can define which category you’d like to search, for example “title:hobbit” will search for hobbit in just title categories. Example: qualifiers: [:t, :titre, :title] (use it for example with multiple languages). Default is the name of the category.
    # * qualifier: Convenience options if you just need a single qualifier, see above. Example: qualifiers => :title. Default is the name of the category.
    # * source: Use a different source than the index uses. If you think you need that, there might be a better solution to your problem. Please post to the mailing list first with your application.rb :)
    # * from: Take the data from the data category with this name. Example: You have a source Sources::CSV.new(:title, file:'some_file.csv') but you want the category to be called differently. The you use from: define_category(:similar_title, :from => :title).
    #
    def category category_name, options = {}
      category_name = category_name.to_sym

      indexing_category = internal_indexing.define_category category_name, options
      indexed_category  = internal_indexed.define_category  category_name, options

      yield indexing_category, indexed_category if block_given?

      self
    end
    alias define_category category

    # Make this category range searchable with a fixed range. If you need other
    # ranges, define another category with a different range value.
    #
    # Example:
    # You have data values inside 1..100, and you want to have Picky return
    # not only the results for 47 if you search for 47, but also results for
    # 45, 46, or 47.2, 48.9, in a range of 2 around 47, so (45..49).
    #
    # Then you use:
    #  ranged_category :values_inside_1_100, 2
    #
    # Optionally, you give it a precision value to reduce the error margin
    # around 47 (Picky is a bit liberal).
    #   Index::Memory.new :range do
    #     ranged_category :values_inside_1_100, 2, precision: 5
    #   end
    #
    # This will force Picky to maximally be wrong 5% of the given range value
    # (5% of 2 = 0.1) instead of the default 20% (20% of 2 = 0.4).
    #
    # We suggest not to use much more than 5 as a higher precision is more
    # performance intensive for less and less precision gain.
    #
    # == Protip 1
    #
    # Create two ranged categories to make an area search:
    #   Index::Memory.new :area do
    #     ranged_category :x, 1
    #     ranged_category :y, 1
    #   end
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
    def ranged_category category_name, range, options = {}
      precision = options[:precision] || 1

      options = { partial: Partial::None.new }.merge options

      define_category category_name, options do |indexing_category, indexed_category|
        Internals::Indexing::Wrappers::Category::Location.install_on indexing_category, range, precision
        Internals::Indexed::Wrappers::Category::Location.install_on indexed_category, range, precision
      end
    end
    alias define_ranged_category ranged_category

    # HIGHLY EXPERIMENTAL Not correctly working yet. Try it if you feel "beta".
    #
    # Also a range search see #ranged_category, but on the earth's surface.
    #
    # Parameters:
    # * lat_name: The latitude's name as used in #define_category.
    # * lng_name: The longitude's name as used in #define_category.
    # * radius: The distance (in km) around the query point which we search for results.
    #
    # Note: Picky uses a square, not a circle. That should be ok for most usages.
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
    # * lat_from: The data category to take the data for the latitude from.
    # * lng_from: The data category to take the data for the longitude from.
    #
    # TODO Will have to write a wrapper that combines two categories that are
    #      indexed simultaneously, since lat/lng are correlated.
    #
    def geo_categories lat_name, lng_name, radius, options = {} # :nodoc:

      # Extract lat/lng specific options.
      #
      lat_from = options.delete :lat_from
      lng_from = options.delete :lng_from

      # One can be a normal ranged_category.
      #
      ranged_category lat_name, radius*0.00898312, options.merge(from: lat_from)

      # The other needs to adapt the radius depending on the one.
      #
      # Depending on the latitude, the radius of the longitude
      # needs to enlarge, the closer we get to the pole.
      #
      # In our simplified case, the radius is given as if all the
      # locations were on the 45 degree line.
      #
      # This calculates km -> longitude (degrees).
      #
      # A degree on the 45 degree line is equal to ~222.6398 km.
      # So a km on the 45 degree line is equal to 0.01796624 degrees.
      #
      ranged_category lng_name, radius*0.01796624, options.merge(from: lng_from)

    end
    alias define_geo_categories geo_categories
  end

end