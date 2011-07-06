module Backend

  class Base

    attr_reader :bundle_name,
                :prepared,
                :inverted,
                :weights,
                :similarity,
                :configuration,
                :category,
                :identifier

    delegate :index_name, :category_name, :to => :@category

    def initialize bundle_name, category
      @identifier  = "#{category.identifier}:#{bundle_name}"
      @bundle_name = bundle_name
      @category    = category
      @prepared    = File::Text.new category.prepared_index_path
    end

    # Delegators.
    #

    # Retrieving data.
    #
    def retrieve &block
      prepared.retrieve &block
    end

    # Dumping.
    #
    def dump_inverted inverted_hash
      timed_exclaim %Q{"#{identifier}":   => #{inverted}.}
      inverted.dump inverted_hash
    end
    def dump_weights weights_hash
      timed_exclaim %Q{"#{identifier}":   => #{weights}.}
      weights.dump weights_hash
    end
    def dump_similarity similarity_hash
      timed_exclaim %Q{"#{identifier}":   => #{similarity}.}
      similarity.dump similarity_hash
    end
    def dump_configuration configuration_hash
      timed_exclaim %Q{"#{identifier}":   => #{configuration}.}
      configuration.dump configuration_hash
    end

    # Loading.
    #
    def load_inverted
      inverted.load
    end
    def load_similarity
      similarity.load
    end
    def load_weights
      weights.load
    end
    def load_configuration
      configuration.load
    end

    # Cache ok?
    #
    def inverted_cache_ok?
      inverted.cache_ok?
    end
    def similarity_cache_ok?
      similarity.cache_ok?
    end
    def weights_cache_ok?
      weights.cache_ok?
    end

    # Cache small?
    #
    def inverted_cache_small?
      inverted.cache_small?
    end
    def similarity_cache_small?
      similarity.cache_small?
    end
    def weights_cache_small?
      weights.cache_small?
    end

    # Copies the indexes to the "backup" directory.
    #
    def backup
      inverted.backup
      weights.backup
      similarity.backup
      configuration.backup
    end

    # Restores the indexes from the "backup" directory.
    #
    def restore
      inverted.restore
      weights.restore
      similarity.restore
      configuration.restore
    end

    # Delete all index files.
    #
    def delete
      inverted.delete
      weights.delete
      similarity.delete
      configuration.delete
    end

    #
    #
    def to_s
      "#{self.class}(#{prepared}, #{bundle_name}, #{category.identifier})"
    end

  end

end