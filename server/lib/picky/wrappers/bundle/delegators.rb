module Picky

  module Wrappers

    module Bundle

      module IndexingDelegator

        delegate :[]=,
                 :analyze,
                 :clear,
                 :configuration,
                 :dump,
                 :empty,
                 :empty_configuration,
                 :load,
                 :generate_caches_from_memory,
                 :generate_caches_from_source,
                 :generate_partial_from,
                 :inverted,
                 :retrieve,
                 :similarity,
                 :size,
                 :weights,
                 :to => :bundle

      end

      module IndexedDelegator

        delegate :identifier,
                 :ids,
                 :name,
                 :similar,
                 :weight,
                 :[],
                 :to => :bundle

      end

    end

  end

end