class Category
  
  attr_reader :name,
              :index,
              
              :indexing_exact,
              :indexing_partial,
              
              :indexed_exact,
              :indexed_partial
  
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
    
    # TODO Push into Bundle. At least the weights.
    #
    @partial_strategy = options[:partial]    || Generators::Partial::Default
    weights           = options[:weights]    || Generators::Weights::Default
    similarity        = options[:similarity] || Generators::Similarity::Default

    @indexing_exact   = index.indexing_bundle_class.new(:exact,   self, similarity, Generators::Partial::None.new, weights)
    @indexing_partial = index.indexing_bundle_class.new(:partial, self, Generators::Similarity::None.new, partial, weights)
    
    # Indexed.
    #
    # TODO Push the defaults out into the index.
    #
    @partial_strategy = partial || Generators::Partial::Default
    similarity        = options[:similarity] || Generators::Similarity::Default

    @indexed_exact   = index.indexed_bundle_class.new :exact,   self, similarity
    @indexed_partial = index.indexed_bundle_class.new :partial, self, similarity

    # @exact   = exact_lambda.call(@exact, @partial)   if exact_lambda   = options[:exact_lambda]
    # @partial = partial_lambda.call(@exact, @partial) if partial_lambda = options[:partial_lambda]

    # TODO Extract? Yes.
    #
    Query::Qualifiers.add(name, generate_qualifiers_from(options) || [name])
  end
  
  # # Indexes and reloads the category.
  # #
  # def reindex
  #   index
  #   reload
  # end
  
  # Category name.
  #
  def category_name
    name
  end
  
  # Index name.
  #
  def index_name
    @index.name
  end

  # Path and partial filename of a specific index on this category.
  #
  def index_path bundle_name, type
    "#{index_directory}/#{name}_#{bundle_name}_#{type}"
  end

  # Path and partial filename of the prepared index on this category.
  #
  def prepared_index_path
    @prepared_index_path ||= "#{index_directory}/prepared_#{name}_index"
  end
  def prepared_index_file &block
    @prepared_index_file ||= Backend::File::Text.new prepared_index_path
    @prepared_index_file.open_for_indexing &block
  end
  
  # The index directory for this category.
  #
  def index_directory
    @index_directory ||= "#{PICKY_ROOT}/index/#{PICKY_ENVIRONMENT}/#{@index.name}"
  end
  
  # Creates the index directory including all necessary paths above it.
  #
  def prepare_index_directory
    FileUtils.mkdir_p index_directory
  end

  # Identifier for internal use.
  #
  # TODO What internal use?
  #
  def identifier
    @identifier ||= "#{@index.name}:#{name}"
  end
  
  def to_info
<<-CATEGORY
Category(#{name}):
Exact:
#{exact.indented_to_s(4)}
Partial:
#{partial.indented_to_s(4)}
CATEGORY
  end
  
  def to_s
    "#{@index.name} #{name}"
  end
  
end