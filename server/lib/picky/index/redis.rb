module Index

  # An index that is persisted in Redis.
  #
  class Redis < Base
    
    def indexing_bundle_class
      Indexing::Bundle::Redis
    end
    def indexed_bundle_class
      Indexed::Bundle::Redis
    end

  end

end