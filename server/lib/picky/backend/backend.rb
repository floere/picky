module Internals

  module Index

    class Backend

      attr_reader :bundle_name
      attr_reader :prepared, :index, :weights, :similarity, :configuration

      delegate :index_name, :category_name, :to => :@category

      def initialize bundle_name, category
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
      def dump_index index_hash
        index.dump index_hash
      end
      def dump_weights weights_hash
        weights.dump weights_hash
      end
      def dump_similarity similarity_hash
        similarity.dump similarity_hash
      end
      def dump_configuration configuration_hash
        configuration.dump configuration_hash
      end

      # Loading.
      #
      def load_index
        index.load
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
      def index_cache_ok?
        index.cache_ok?
      end
      def similarity_cache_ok?
        similarity.cache_ok?
      end
      def weights_cache_ok?
        weights.cache_ok?
      end

      # Cache small?
      #
      def index_cache_small?
        index.cache_small?
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
        index.backup
        weights.backup
        similarity.backup
        configuration.backup
      end

      # Restores the indexes from the "backup" directory.
      #
      def restore
        index.restore
        weights.restore
        similarity.restore
        configuration.restore
      end

      # Delete all index files.
      #
      def delete
        index.delete
        weights.delete
        similarity.delete
        configuration.delete
      end

    end

  end

end