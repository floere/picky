module Picky
  # Use this class to extend the hash the serializer returns.
  #
  module Convenience

    # Are there any allocations?
    #
    def empty?
      allocations.empty?
    end
    # Returns the topmost limit results.
    #
    def ids limit = 20
      ids = []
      allocations.each { |allocation| allocation[4].each { |id| break if ids.size > limit; ids << id } }
      ids
    end
    # Removes the ids from each allocation.
    #
    def clear_ids
      allocations.each { |allocation| allocation[4].clear }
    end

    # Caching readers.
    #
    def allocations
      @allocations || @allocations = self[:allocations]
    end
    def allocations_size
      @allocations_size || @allocations_size = allocations.size
    end
    def total
      @total || @total = self[:total]
    end
    
    # Populating the results.
    #
    # Give it an AR class and options for the find and it
    # will yield each found result for you to render.
    #
    # If you don't pass it a block, it will just use the AR results.
    #
    def populate_with klass, amount = 20, options = {}, &block
      the_ids = ids amount
      
      objects = klass.find the_ids, options
      
      # Put together a mapping.
      #
      mapped_entries = objects.inject({}) do |mapped, entry|
        mapped[entry.id] = entry if entry
        mapped
      end
      
      # Preserves the order
      #
      objects = the_ids.map { |id| mapped_entries[id] }
      
      objects.collect! &block if block_given?
      
      replace_ids_with objects
      clear_ids
      
      objects
    end
    # The rendered results or AR instances if you
    # have populated the results.
    #
    def entries limit = 20
      if block_given?
        i = 0
        allocations.each { |allocation| allocation[5].collect! { |ar_or_rendered| break if i >= limit; i = i + 1; yield ar_or_rendered } }
      else
        entries = []
        allocations.each { |allocation| allocation[5].each { |ar_or_rendered| break if entries.size >= limit; entries << ar_or_rendered } }
        entries
      end
    end
    
    # The ids need to come in the order which the ids were returned by the ids method.
    #
    def replace_ids_with entries
      i = 0
      self.allocations.each do |allocation|
        allocation[5] = allocation[4].map do |_|
          e = entries[i]
          i += 1
          e
        end
      end
    end
    
  end
end