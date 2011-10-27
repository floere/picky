module Picky

  # Use this class to extend the hash that the client returns.
  #
  module Convenience

    # Are there any allocations?
    #
    def empty?
      allocations.empty?
    end

    # Returns the topmost n results.
    # (Note that not all ids are returned with the results. By default only maximally 20.)
    #
    # === Parameters
    # * limit: The amount of ids to return. Default is all of them.
    #
    def ids limit = nil
      ids = []
      allocations.each { |allocation| allocation[4].each { |id| break if limit && ids.size > limit; ids << id } }
      ids
    end

    # Returns the allocations.
    #
    def allocations
      @allocations ||= self[:allocations]
    end

    # Returns the total of results.
    #
    def total
      @total ||= self[:total]
    end

    # Populates the ids with (rendered) model instances.
    #
    # Give it an AR class and options for the find and it
    # will yield each found result for you to render.
    #
    # If you don't pass it a block, it will just use the AR results.
    #
    # === Parameters
    # * model_class: The model to use for the results. Will call #find on the given class.
    #
    # === Options
    # * up_to: Amount of results to populate. All of them by default.
    # * The rest of the options are directly passed through to the ModelClass.find(ids, options) method. Default is {}.
    #
    def populate_with model_class, options = {}, &block
      the_ids = ids options.delete(:up_to)

      objects = model_class.find the_ids, options

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

      amend_ids_with objects
      clear_ids

      objects
    end

    # Returns either
    # * the rendered entries, if you have used #populate_with _with_ a block
    # OR
    # * the model instances, if you have used #populate_with _without_ a block
    #
    # Or, if you haven't called #populate_with yet, you will get an empty array.
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
    def amend_ids_with entries # :nodoc:
      i = 0
      allocations.each do |allocation|
        allocation[5] = allocation[4].map do |_|
          e = entries[i]
          i += 1
          e
        end
      end
    end

    # Removes all ids of each allocation.
    #
    def clear_ids
      allocations.each { |allocation| allocation[4].clear }
    end

  end
end