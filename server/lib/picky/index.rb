module Picky

  # = Picky Indexes
  #
  # A Picky Index defines
  # * what backend it uses.
  # * where its data comes from (a data source).
  # * how this data it is indexed.
  # * a number of categories that may or may not map directly to data categories.
  #
  # == Howto
  #
  # This is a step-by-step description on how to create an index.
  #
  # Start by choosing an <tt>Index</tt> or an <tt>Index</tt>.
  # In the example, we will be using an in-memory index, <tt>Index</tt>.
  #
  #   books = Index.new(:books)
  #
  # That in itself won't do much good, that's why we add a data source:
  #
  #   books = Index.new(:books) do
  #     source Sources::CSV.new(:title, :author, file: 'data/books.csv')
  #   end
  #
  # In the example, we use an explicit <tt>Sources::CSV</tt> of Picky.
  # However, anything that responds to <tt>#each</tt>, and returns an object that
  # answers to <tt>#id</tt>, works.
  #
  # For example, a 3.0 ActiveRecord class:
  #
  #   books = Index.new(:books) do
  #     source Book.order('isbn ASC')
  #   end
  #
  # Now we know where the data comes from, but not, how to categorize it.
  #
  # Let's add a few categories:
  #
  #   books = Index.new(:books) do
  #     source   Book.order('isbn ASC')
  #     category :title
  #     category :author
  #     category :isbn
  #   end
  #
  # Categories offer quite a few options, see <tt>Indexes::Base#category</tt> for details.
  #
  # After adding more options, it might look like this:
  #
  #   books = Index.new(:books) do
  #     source   Book.order('isbn ASC')
  #     category :title,
  #              partial: Partial::Substring.new(from: 1),
  #              similarity: Similarity::DoubleMetaphone.new(3),
  #              qualifiers: [:t, :title, :titulo]
  #     category :author,
  #              similarity: Similarity::Metaphone.new(2)
  #     category :isbn,
  #              partial: Partial::None.new,
  #              from: :legacy_isbn_name
  #   end
  #
  # For this to work, a <tt>Book</tt> should support methods <tt>#title</tt>, <tt>#author</tt> and <tt>#legacy_isbn_name</tt>.
  #
  # If it uses <tt>String</tt> ids, use <tt>#key_format</tt> to define a formatting method:
  #
  #   books = Index.new(:books) do
  #     key_format :to_s
  #     source     Book.order('isbn ASC')
  #     category   :title
  #     category   :author
  #     category   :isbn
  #   end
  #
  # Finally, use the index for a <tt>Search</tt>:
  #
  #   route %r{^/media$} => Search.new(books, dvds, mp3s)
  #
  # This class defines the indexing and index API that is exposed to the user
  # as the #index method inside the Application class.
  #
  # It provides a single front for both indexing and index options. We suggest to always use the index API.
  #
  # Note: An Index holds both an *Indexed*::*Index* and an *Indexing*::*Index*.
  #
  class Index

    attr_reader :name,
                :categories,
                :hints

    forward :[],
            :dump,
            :each,
            :inject,
            :reset_backend,
            :to => :categories

    # Create a new index with a given source.
    #
    # === Parameters
    # * name: A name that will be used for the index directory and in the Picky front end.
    #
    # === Options (all are used in the block - not passed as a Hash, see examples)
    # * source: Where the data comes from, e.g. Sources::CSV.new(...). Optional, can be defined in the block using #source.
    # * result_identifier: Use if you'd like a different identifier/name in the results than the name of the index.
    # * after_indexing: As of this writing only used in the db source. Executes the given after_indexing as SQL after the indexing process.
    # * indexing: Call and pass either a tokenizer (responds to #tokenize) or the options for a tokenizer..
    # * key_format: Call and pass in a format method for the ids (default is #to_i).
    #
    # Example:
    #   my_index = Index.new(:my_index) do
    #     source            Sources::CSV.new(file: 'data/index.csv')
    #     key_format        :to_sym
    #     category          :bla
    #     result_identifier :my_special_results
    #   end
    #
    def initialize name
      @name       = name.intern
      @categories = Categories.new

      # Centralized registry.
      #
      Indexes.register self

      instance_eval(&Proc.new) if block_given?
    end
    
    # Provide hints for Picky so it can optimise.
    #
    def optimize *hints
      require_relative 'index/hints'
      @hints = Hints.new hints
    end
    
    # Explicitly trigger memory optimization.
    #
    def optimize_memory array_references = Hash.new
      dedup = Picky::Optimizers::Memory::ArrayDeduplicator.new
      dedup.deduplicate categories.map(&:exact).map(&:inverted), array_references
      dedup.deduplicate categories.map(&:partial).map(&:inverted), array_references
    end

    # TODO Doc.
    #
    def static
      @static = true
    end
    def static?
      @static
    end

    # API method.
    #
    # Sets/returns the backend used.
    # Default is @Backends::Memory.new@.
    #
    def backend backend = nil
      if backend
        @backend = backend
        reset_backend
      else
        @backend ||= Backends::Memory.new
      end
    end

    # API method.
    #
    def symbol_keys value = nil
      if value
        @symbol_keys = value
      else
        @symbol_keys
      end 
    end

    # The directory used by this index.
    #
    # Note: Used @directory ||=, but needs to be dynamic.
    #
    def directory
      ::File.join(Picky.root, 'index', PICKY_ENVIRONMENT, name.to_s)
    end

    # Restrict categories to the given ones.
    #
    # Functionally equivalent as if indexes didn't
    # have the categories at all.
    #
    # Note: Probably only makes sense when an index
    # is used in multiple searches. If not, why even
    # have the categories?
    #
    # TODO Redesign.
    #
    def only *qualifiers
      raise "Sorry, Picky::Search#only has been removed in version."
      # @qualifier_mapper.restrict_to *qualifiers
    end

    # TODO Reinstate.
    #
    # # Ignore the categories with these qualifiers.
    # #
    # # Example:
    # #   search = Search.new(index1, index2, index3) do
    # #     ignore :name, :first_name
    # #   end
    # #
    # # Cleans up / optimizes after being called.
    # #
    # def ignore *qualifiers
    #   @ignored_categories ||= []
    #   @ignored_categories += qualifiers.map { |qualifier| @qualifier_mapper.map qualifier }.compact
    #   @ignored_categories.uniq!
    # end

    # API method.
    #
    # Defines a searchable category on the index.
    #
    # === Parameters
    # * category_name: This identifier is used in the front end, but also to categorize query text. For example, “title:hobbit” will narrow the hobbit query on categories with the identifier :title.
    #
    # === Options
    # * indexing: Pass in either a tokenizer or tokenizer options.
    # * partial: Partial::None.new or Partial::Substring.new(from: starting_char, to: ending_char). Default is Partial::Substring.new(from: -3, to: -1).
    # * similarity: Similarity::None.new or Similarity::DoubleMetaphone.new(similar_words_searched). Default is Similarity::None.new.
    # * qualifiers: An array of qualifiers with which you can define which category you’d like to search, for example “title:hobbit” will search for hobbit in just title categories. Example: qualifiers: [:t, :titre, :title] (use it for example with multiple languages). Default is the name of the category.
    # * qualifier: Convenience options if you just need a single qualifier, see above. Example: qualifiers => :title. Default is the name of the category.
    # * source: Use a different source than the index uses. If you think you need that, there might be a better solution to your problem. Please post to the mailing list first with your application.rb :)
    # * from: Take the data from the data category with this name. Example: You have a source Sources::CSV.new(:title, file:'some_file.csv') but you want the category to be called differently. The you use from: category(:similar_title, :from => :title).
    #
    def category category_name, options = {}
      new_category = Category.new category_name.intern, self, options
      categories << new_category

      new_category = yield new_category if block_given?

      new_category
    end

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
    #   Index.new :range do
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
    #   Index.new :area do
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
    # * category_name: The category_name as used in #category.
    # * range: The range (in the units of your data values) around the query point where we search for results.
    #
    #  -----|<- range  ->*------------|-----
    #
    # === Options
    # * precision: Default is 1 (20% error margin, very fast), up to 5 (5% error margin, slower) makes sense.
    # * anchor: Where to anchor the grid.
    # * ... all options of #category.
    #
    def ranged_category category_name, range, options = {}
      precision = options.delete(:precision) || 1
      anchor    = options.delete(:anchor)    || 0.0

      # Note: :key_format => :to_f ?
      #
      options = { partial: Partial::None.new }.merge options

      category category_name, options do |cat|
        Category::Location.install_on cat, range, precision, anchor
      end
    end

    # Geo search, searches in a rectangle (almost square) in the lat/long coordinate system.
    #
    # Note: It uses #ranged_category.
    #
    # Parameters:
    # * lat_name: The latitude's name as used in #category.
    # * lng_name: The longitude's name as used in #category.
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
    # THINK Will have to write a wrapper that combines two categories that are
    # indexed simultaneously, since lat/lng are correlated.
    #
    def geo_categories lat_name, lng_name, radius, options = {}
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

    def to_stats
      stats = <<-INDEX
#{name} (#{self.class}):
#{"source:            #{source}".indented_to_s}
#{"categories:        #{categories.to_stats}".indented_to_s}
INDEX
      stats << "result identifier: \"#{result_identifier}\"".indented_to_s unless result_identifier.to_s == name.to_s
      stats << "\n"
      stats
    end

    # Identifier used for technical output.
    #
    def identifier
      name
    end

    #
    #
    def to_s
      s = [
        name,
        "result_id: #{result_identifier}",
        ("source: #{source}" if @source),
        ("categories: #{categories}" unless categories.empty?)
      ].compact
      "#{self.class}(#{s.join(', ')})"
    end

    # Displays the structure as a tree.
    #
    def to_tree_s indent = 0
      <<-TREE
#{' ' * indent}Index(#{name})
#{' ' * indent}  source: #{source.to_s[0..40]}
#{' ' * indent}  result identifier: "#{result_identifier}"
#{' ' * indent}  categories:
#{' ' * indent}#{categories.to_tree_s(4)}
TREE
    end

  end

end