module Picky

  module Wrappers

    module Bundle

      module Delegator

        delegate :add,

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

                 :to => :bundle

      end

      module IndexingDelegator

        delegate :[]=,
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

        delegate :[],
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