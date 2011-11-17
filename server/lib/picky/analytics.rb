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

  end

end