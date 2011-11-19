module Picky

  # This class is wrapped around indexes
  # and extracts useful information to be
  # displayed in beoootiful, live-updating
  # graphs.
  #
  class Analytics

    attr_reader :indexes

    def initialize *indexes
      @indexes = Indexes.new *indexes
    end

    # Returns the number of tokens in all the inverted indexes.
    #
    def tokens
      total = 0
      indexes.each_bundle do |bundle|
        total += bundle.inverted.size
      end
      total
    end

    def ids
      total = 0
      indexes.each_bundle do |bundle|
        total += bundle.inverted.inject(0) { |total, (_, values)| total + values.size }
      end
      total
    end

    # def lengths index
    #   min_ids_length = 1.0/0 # Infinity
    #   max_ids_length =     0
    #   min_key_length = 1.0/0 # Infinity
    #   max_key_length =     0
    #
    #   key_size, ids_size = 0, 0
    #   bundle.each_pair do |key, ids|
    #     key_size = key.size
    #     if key_size < min_key_length
    #       min_key_length = key_size
    #     else
    #       max_key_length = key_size if key_size > max_key_length
    #     end
    #     key_length_average += key_size
    #
    #     ids_size = ids.size
    #     if ids_size < min_ids_length
    #       min_ids_length = ids_size
    #     else
    #       max_ids_length = ids_size if ids_size > max_ids_length
    #     end
    #     ids_length_average += ids_size
    #   end
    #   index_size = index.size
    #   key_length_average = key_length_average.to_f / index_size
    #   ids_length_average = ids_length_average.to_f / index_size
    #
    #   [
    #     Lengths.new(index_size, key_length_average, (min_key_length..max_key_length)),
    #     Lengths.new(index_size, ids_length_average, (min_ids_length..max_ids_length))
    #   ]
    # end
    #
    # # Contains an average and a range.
    # #
    # class Lengths
    #
    #   def initialize size, average, range
    #     @size, @average, @range = size, average, range
    #   end
    #
    # end

  end

end