module Picky

  class Category

    include API::Tokenizer

    attr_accessor :exact,
                  :partial
    attr_reader :name,
                :backend
    attr_writer :source

    # Parameters:
    #  * name: Category name to use as identifier and file names.
    #  * index: Index to which this category is attached to.
    #
    # Options:
    #  * partial: Partial::None.new, Partial::Substring.new(from:start_char, to:up_to_char)
    #  (defaults from:-3, to:-1)
    #  * similarity: Similarity::None.new (default),
    #  Similarity::DoubleMetaphone.new(amount_of_similarly_linked_words)
    #  * from: The source category identifier to take the data from.
    #  * key_format: What this category's keys are formatted with (default is :to_i)
    #  * backend: The backend to use. Default is Backends::Memory.new.
    #  Other options are: Backends::Redis.new, Backends::SQLite.new, Backends::File.new.
    #  * qualifiers: Which qualifiers can be used to predefine the category. E.g. "title:bla".
    #
    # Advanced Options:
    #  * source: Use if the category should use a different source.
    #  * tokenize: Whether to use the tokenizer (default is true).
    #  * tokenizer: Use a subclass of Tokenizers::Base that implements #tokens_for and #empty_tokens.
    #  * weight: Weights::Logarithmic.new, Weights::Constant.new(int = 0),
    #  Weights::Dynamic.new(&block) or an object that responds
    #  to #weight_for(amount_of_ids_for_token) and returns a float.
    #
    def initialize name, index, options = {}
      @name  = name
      @index = index
      
      # TODO Move.
      #
      options[:hints] = index.hints

      configure_from options
      configure_indexes_from options
    end
    
    def configure_from options
      @from       = options.delete :from
      
      # Instantly extracted to raise an error instantly.
      #
      @source     = Source.from options[:source], true, @index.name
      @tokenize   = options[:tokenize] != false
      @tokenizer  = Tokenizer.from options[:indexing], @index.name, name
      @ranger     = options[:ranging] || Range

      @key_format  = options.delete :key_format
      @backend     = options.delete :backend

      @qualifiers  = extract_qualifiers_from options

      @symbol_keys = options[:symbol_keys] || @index.symbol_keys # SYMBOLS.
    end
    
    def symbol_keys?
      @symbol_keys
    end

    # TODO I do a lot of helper method calls here. Refactor?
    #
    def configure_indexes_from options
      warn_if_unknown options
      
      weights    = weights_from options
      partial    = partial_from options
      similarity = similarity_from options
      
      @exact     = exact_for weights, similarity, options
      @partial   = partial_for @exact, partial, weights, options
    end
    # Since the options hash might contain options that do not exist,
    # we should warn people if they use the wrong options.
    # (Problem is that if the option is not found, then Picky will use the default)
    #
    # TODO Rewrite it such that this does not need to be maintained separately (and gets available options automatically).
    #
    @@known_keys = [
      :hints,
      :indexing,
      :partial,
      :qualifier,
      :qualifiers,
      :ranging,
      :similarity,
      :source,
      :tokenize,
      :tokenizer,
      :weight,
    ]
    def warn_if_unknown options
      if options && (options.keys - @@known_keys).size > 0
        warn <<-WARNING

Warning: Category options #{options} for category #{name} contain an unknown option.
         Working options are: #@@known_keys.
WARNING
      end
    end
    def weights_from options
      Generators::Weights.from options[:weight], index_name, name
    end
    def partial_from options
      Generators::Partial.from options[:partial], index_name, name
    end
    def similarity_from options
      Generators::Similarity.from options[:similarity], index_name, name
    end
    def exact_for weights, similarity, options
      Bundle.new :exact, self, weights, Generators::Partial::None.new, similarity, options
    end
    def partial_for exact, partial_options, weights, options
      # TODO Also partial.extend Bundle::Exact like in the category.
      #
      # Instead of exact for partial, use respond_to? :exact= on eg. Partial::None, then set it on the instance? 
      #
      if partial_options.respond_to?(:use_exact_for_partial?) && partial_options.use_exact_for_partial?
        Wrappers::Bundle::ExactPartial.new exact
      else
        Bundle.new :partial, self, weights, partial_options, Generators::Similarity::None.new, options
      end
    end
    
    # Lazily create a prepared index proxy.
    #
    def prepared
      @prepared ||= Backends::Prepared::Text.new prepared_index_path
    end
    
    # Indexes and loads the category.
    #
    def reindex
      index
      load
    end

    # Dumps both bundles.
    #
    def dump
      exact.dump
      partial.dump
      Picky.logger.dump self
    end

    # Returns the backend.
    #
    # If no specific backend has been defined for this
    #
    def backend
      @backend || @index.backend
    end
    # Resets backends in both bundles.
    #
    def reset_backend
      exact.reset_backend
      partial.reset_backend
    end

    # Returns the qualifiers if set or
    # just the name if not.
    #
    def qualifiers
      @qualifiers || [name]
    end
    # Extract qualifiers from the options.
    #
    def extract_qualifiers_from options
      options[:qualifiers] || options[:qualifier] && [options[:qualifier]]
    end

    # The category itself just yields itself.
    #
    def each_category
      yield self
    end

    # Path and partial filename of the prepared index on this category.
    #
    def prepared_index_path
      @prepared_index_path ||= ::File.join(index_directory, name.to_s)
    end
    # Get an opened index file.
    #
    # Note: If you don't use it with the block, do not forget to close it.
    #
    def prepared_index_file &block
      @prepared_index_file ||= Backends::Prepared::Text.new prepared_index_path
      @prepared_index_file.open &block
    end
    
    def index_directory
      @index.directory
    end
    def index_name
      @index.name
    end

    # Identifier for technical output.
    #
    def identifier
      :"#{@index.identifier}:#{name}"
    end
    
    # Uniquely identified by index name and name.
    #
    def == other
      return false unless other
      index_name == other.index_name &&
      name       == other.name
    end

    #
    #
    def to_s
      "#{self.class}(#{identifier})"
    end
    
    def to_tree_s indent = 0
      s = <<-TREE
#{' ' * indent}#{self.class.name.gsub('Picky::','')}(#{name})
#{' ' * indent}  #{exact.to_tree_s(4)}
#{' ' * indent}  #{partial.to_tree_s(4)}
TREE
      s.chomp
    end

  end

end
