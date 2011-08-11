module Picky

  # This is the internal results object. Usually, to_marshal, or to_json
  # is called on it to get a string for the answer.
  #
  class Results

    # Duration is set externally by the query.
    #
    attr_writer :duration
    attr_reader :allocations, :offset, :amount

    # Takes instances of Query::Allocations as param.
    #
    def initialize amount = 0, offset = 0, allocations = Query::Allocations.new
      @offset      = offset
      @amount      = amount
      @allocations = allocations
    end
    # Create new results and calculate the ids.
    #
    def self.from amount, offset, allocations
      results = new amount, offset, allocations
      results.prepare!
      results
    end

    # Returns a hash with the allocations, offset, duration and total.
    #
    def to_hash
      { allocations: allocations.to_result,
        offset:      offset,
        duration:    duration,
        total:       total }
    end
    # Convert to json format.
    #
    def to_json options = {}
      to_hash.to_json options
    end

    # This starts the actual processing.
    #
    # Without this, the allocations are not processed,
    # and no ids are calculated.
    #
    def prepare!
      allocations.process! amount, offset
    end

    # Duration default is 0.
    #
    def duration
      @duration || 0
    end
    # The total results. Delegates to the allocations.
    #
    # Caches.
    #
    def total
      @total || @total = allocations.total || 0
    end

    # Convenience methods.
    #

    # Delegates to allocations.
    #
    def ids amount = 20
      allocations.ids amount
    end

    # Human readable log.
    #
    # TODO Should this be to_s? (And it should also hold the original query?)
    #
    def to_log query
      "#{log_type}|#{Time.now.to_s(:db)}|#{'%8f' % duration}|#{'%-50s' % query}|#{'%8d' % total}|#{'%4d' % offset}|#{'%2d' % allocations.size}|"
    end
    # The first character in the blog designates what type of query it is.
    #
    # No calculated ids means: No results.
    #
    def log_type
      amount.zero?? :'.' : :'>'
    end

  end

end