class Indexes

  # An index that is persisted in files, loaded at startup and kept in memory at runtime.
  #
  class Memory < Base

    def indexing_bundle_class
      Indexing::Bundle::Memory
    end
    def indexed_bundle_class
      Indexed::Bundle::Memory
    end

  end

end