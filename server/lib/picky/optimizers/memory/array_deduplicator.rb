module Picky::Optimizers::Memory
  
  # Straightforward implementation of an array deduplicator.
  # Tries to find duplicate instances of Array values in a hash
  # and points references that point to a duplicate to one of the
  # Array instances.
  #
  # TODO Could we have C-Ruby point to parts of another Array?
  #
  class ArrayDeduplicator
    
    def deduplicate hashes, array_references = Hash.new
      hashes.inject(array_references) do |array_references, hash|
        deduplicate_hash hash, array_references
        array_references
      end
    end
    
    def deduplicate_hash hash, array_references
      hash.each do |k, ary|
        stored_ary = if array_references.has_key?(ary)
          array_references.fetch ary
        else
          # Prepare ary for reference cache.
          compact_ary = compact ary
          # Cache ary.
          array_references.store ary, compact_ary
        end
        
        hash[k] = stored_ary
      end
    end
    
    def compact ary
      Array[*ary]
    end
    
  end
end