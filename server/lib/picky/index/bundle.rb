# encoding: utf-8
#
module Index

  # This is the ACTUAL index.
  #
  # Handles exact index, partial index, weights index, and similarity index.
  #
  class Bundle
    
    attr_reader   :checker
    attr_reader   :name,             :category,         :type
    attr_accessor :index,            :weights,          :similarity
    attr_accessor :partial_strategy, :weights_strategy, :similarity_strategy
    
    delegate :[], :[]=, :clear, :to => :index
    delegate :raise_unless_cache_exists, :to => :checker
    
    # Path is in which directory the cache is located.
    #
    def initialize name, category, type, partial_strategy, weights_strategy, similarity_strategy
      @index      = {}
      @weights    = {}
      @similarity = {}
      
      @name     = name
      @category = category
      @type     = type
      
      @partial_strategy    = partial_strategy
      @weights_strategy    = weights_strategy
      @similarity_strategy = similarity_strategy
      
      @checker = BundleChecker.new self
    end
    
    # Get the ids for the text.
    #
    def ids text
      @index[text] || []
    end
    # Get a weight for the text.
    #
    def weight text
      @weights[text]
    end
    # Get a list of similar texts.
    #
    def similar text
      code = similarity_strategy.encoded text
      code && @similarity[code] || []
    end

    # Identifier for this bundle.
    #
    def identifier
      "#{name}: #{type.name} #{category.name}"
    end
    
    # Point to category.
    #
    def search_index_root
      File.join PICKY_ROOT, 'index'
      # category.search_index_root
    end

    # Copies the indexes to the "backup" directory.
    #
    def backup
      target = backup_path
      FileUtils.mkdir target unless Dir.exists?(target)
      FileUtils.cp index_cache_path,      target, :verbose => true
      FileUtils.cp similarity_cache_path, target, :verbose => true
      FileUtils.cp weights_cache_path,    target, :verbose => true
    end
    def backup_path
      File.join File.dirname(index_cache_path), 'backup'
    end

    # Restores the indexes from the "backup" directory.
    #
    def restore
      FileUtils.cp backup_file_path_of(index_cache_path), index_cache_path, :verbose => true
      FileUtils.cp backup_file_path_of(similarity_cache_path), similarity_cache_path, :verbose => true
      FileUtils.cp backup_file_path_of(weights_cache_path), weights_cache_path, :verbose => true
    end
    def backup_file_path_of path
      dir, name = File.split path
      File.join dir, 'backup', name
    end

    # Delete the file at path.
    #
    def delete path
      `rm -Rf #{path}`
    end
    # Delete all index files.
    #
    def delete_all
      delete index_cache_path
      delete similarity_cache_path
      delete weights_cache_path
    end

    # Create directory and parent directories.
    #
    def create_directory
      FileUtils.mkdir_p cache_directory
    end
    # TODO Move to config. Duplicate Code in field.rb.
    #
    def cache_directory
      File.join search_index_root, PICKY_ENVIRONMENT, type.name.to_s
    end

    # Generates a cache path.
    #
    def cache_path text
      File.join cache_directory, "#{name}_#{text}"
    end
    def index_cache_path
      cache_path "#{category.name}_index"
    end
    def similarity_cache_path
      cache_path "#{category.name}_similarity"
    end
    def weights_cache_path
      cache_path "#{category.name}_weights"
    end
    
    # Loads all indexes into this category.
    #
    def load
      load_index
      load_similarity
      load_weights
    end
    def load_the_json path
      Yajl::Parser.parse File.open("#{path}.json", 'r'), :symbolize_keys => true
    end
    def load_the_marshalled path
      Marshal.load File.open("#{path}.dump", 'r:binary')
    end
    def load_index
      timed_exclaim "Loading the index for #{identifier} from the cache."
      self.index = load_the_json index_cache_path
    end
    def load_similarity
      timed_exclaim "Loading the similarity for #{identifier} from the cache."
      self.similarity = load_the_marshalled similarity_cache_path
    end
    def load_weights
      timed_exclaim "Loading the weights for #{identifier} from the cache."
      self.weights = load_the_json weights_cache_path
    end
    
    # Generation
    #
    
    # This method
    # * loads the base index from the db
    # * generates derived indexes
    # * dumps all the indexes into files
    #
    def generate_caches_from_source
      load_from_index_file
      generate_caches_from_memory
    end
    # Generates derived indexes from the index and dumps.
    #
    # Note: assumes that there is something in the index
    #
    def generate_caches_from_memory
      cache_from_memory_generation_message
      generate_derived
    end
    def cache_from_memory_generation_message
      timed_exclaim "CACHE FROM MEMORY #{identifier}."
    end
    
    # Generates the weights and similarity from the main index.
    #
    def generate_derived
      generate_weights
      generate_similarity
    end
    
    # Load the data from the db.
    #
    def load_from_index_file
      load_from_index_generation_message
      clear
      retrieve
    end
    def load_from_index_generation_message
      timed_exclaim "LOAD INDEX #{identifier}."
    end
    # Retrieves the data into the index.
    #
    # TODO Beautify.
    #
    def retrieve
      # TODO Make r:binary configurable!
      #
      File.open(search_index_file_name, 'r:binary') do |file|
        file.each_line do |line|
          indexed_id, token = line.split ?,,2
          token.chomp!
          token = token.to_sym
          
          initialize_index_for token
          index[token] << indexed_id.to_i
        end
      end
    end
    def initialize_index_for token
      index[token] ||= []
    end
    # TODO Duplicate code!
    #
    # TODO Use config object?
    #
    def search_index_file_name
      File.join cache_directory, "prepared_#{category.name}_index.txt"
    end
    
    # Generators.
    #
    # TODO Move somewhere more fitting.
    #
    
    # Generates a new index (writes its index) using the
    # given partial caching strategy.
    #
    def generate_partial
      generator = Cacher::PartialGenerator.new self.index
      self.index = generator.generate self.partial_strategy
    end
    def generate_partial_from exact_index
      timed_exclaim "PARTIAL GENERATE #{identifier}."
      self.index = exact_index
      self.generate_partial
      self
    end
    # Generates a new similarity index (writes its index) using the
    # given similarity caching strategy.
    #
    def generate_similarity
      generator = Cacher::SimilarityGenerator.new self.index
      self.similarity = generator.generate self.similarity_strategy
    end
    # Generates a new weights index (writes its index) using the
    # given weight caching strategy.
    #
    def generate_weights
      generator = Cacher::WeightsGenerator.new self.index
      self.weights = generator.generate self.weights_strategy
    end

    # Saves the index in a dump file.
    #
    def dump
      dump_index
      dump_similarity
      dump_weights
    end
    def dump_index
      timed_exclaim "DUMP INDEX #{identifier}."
      index.dump_to_json index_cache_path
    end
    # Note: We marshal the similarity, as the
    #       Yajl json lib cannot load symbolized
    #       values, just keys.
    #
    def dump_similarity
      timed_exclaim "DUMP SIMILARITY #{identifier}."
      similarity.dump_to_marshalled similarity_cache_path
    end
    def dump_weights
      timed_exclaim "DUMP WEIGHTS #{identifier}."
      weights.dump_to_json weights_cache_path
    end

  end
end