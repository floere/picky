module Picky

  module Wrappers

    module Bundle

      module Delegator

        forward :add,

                :inverted,
                :weights,
                :similarity,
                :configuration,

                :backup,
                :restore,
                :delete,

                :reset_backend,

                :raise_unless_cache_exists,
                :raise_unless_index_exists,
                :raise_unless_similarity_exists,

                :similar,
                
                :to_tree_s,

                :to => :bundle

      end

      module IndexingDelegator

        forward :[]=,
                :analyze,
                :dump,
                :empty,
                :empty_configuration,
                :generate_caches_from_memory,
                :generate_caches_from_source,
                :generate_partial_from,
                :retrieve,
                :size,
                :to => :bundle

      end

      module IndexedDelegator

        forward :[],
                :add_partialized,
                :clear,
                :clear_inverted,
                :clear_weights,
                :clear_similarity,
                :clear_configuration,
                :clear_realtime,
                :identifier,
                :ids,
                :load,
                :load_inverted,
                :load_weights,
                :load_similarity,
                :load_configuration,
                :name,
                :remove,
                :weight,
                :to => :bundle

      end

    end

  end

end