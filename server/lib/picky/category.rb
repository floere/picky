class Category

  attr_reader :name

  # Mandatory params:
  #  * name: Category name to use as identifier and file names.
  #  * index: Index to which this category is attached to.
  #
  # Options:
  #  * partial: Partial::None.new, Partial::Substring.new(from:start_char, to:up_to_char) (defaults from:-3, to:-1)
  #  * similarity: Similarity::None.new (default), Similarity::DoubleMetaphone.new(amount_of_similarly_linked_words)
  #  * from: The source category identifier to take the data from.
  #
  # Advanced Options:
  #  * source: Use if the category should use a different source.
  #  * weights: Query::Weights.new( [:category1, :category2] => +2, ... )
  #  * tokenizer: Use a subclass of Tokenizers::Base that implements #tokens_for and #empty_tokens.
  #  * key_format: What this category's keys are formatted with (default is :to_i)
  #
  def initialize name, index, options = {}
    @name  = name
    @index = index

    # Indexing.
    #
    @source     = options[:source]
    @from       = options[:from]
    @tokenizer  = options[:tokenizer]
    @key_format = options[:key_format]

    weights    = options[:weights]    || Generators::Weights::Default
    partial    = options[:partial]    || Generators::Partial::Default
    similarity = options[:similarity] || Generators::Similarity::Default

    @indexing_exact   = index.indexing_bundle_class.new :exact,   self, weights, Generators::Partial::None.new, similarity, options
    @indexing_partial = index.indexing_bundle_class.new :partial, self, weights, partial, Generators::Similarity::None.new, options

    # Indexed.
    #
    @indexed_exact  = index.indexed_bundle_class.new  :exact, self, similarity
    if partial.use_exact_for_partial?
      @indexed_partial  = @indexed_exact
    else
      @indexed_partial  = index.indexed_bundle_class.new  :partial, self, similarity
    end

    # @exact   = exact_lambda.call(@exact, @partial)   if exact_lambda   = options[:exact_lambda]
    # @partial = partial_lambda.call(@exact, @partial) if partial_lambda = options[:partial_lambda]

    # TODO Extract? Yes.
    #
    Query::Qualifiers.add(name, generate_qualifiers_from(options) || [name])
  end

  # TODO Move to Search.
  #
  def generate_qualifiers_from options
    options[:qualifiers] || options[:qualifier] && [options[:qualifier]]
  end

  # Indexes and reloads the category.
  #
  def reindex
    index
    reload
  end

  # Category name.
  #
  # TODO Remove? Alias?
  #
  def category_name
    name
  end

  # Index name.
  #
  def index_name
    @index.name
  end

  # The category itself just yields itself.
  #
  def each_category
    yield self
  end

  # Path and partial filename of the prepared index on this category.
  #
  def prepared_index_path
    @prepared_index_path ||= "#{index_directory}/prepared_#{name}_index"
  end
  # Get an opened index file.
  #
  # Note: If you don't use it with the block, do not forget to close it.
  #
  def prepared_index_file &block
    @prepared_index_file ||= Backend::File::Text.new prepared_index_path
    @prepared_index_file.open &block
  end
  # Creates the index directory including all necessary paths above it.
  #
  # Note: Interface method called by any indexers.
  #
  def prepare_index_directory
    FileUtils.mkdir_p index_directory
  end

  # The index directory for this category.
  #
  # TODO Push down into files?
  #
  def index_directory
    @index_directory ||= "#{PICKY_ROOT}/index/#{PICKY_ENVIRONMENT}/#{@index.name}"
  end

  # Identifier for technical output.
  #
  def identifier
    "#{@index.identifier}:#{name}"
  end

  #
  #
  def to_s
    "Category(#{name})"
  end

end