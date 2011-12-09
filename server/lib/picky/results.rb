module Picky

  # This is the internal results object. Usually, to_marshal, or to_json
  # is called on it to get a string for the answer.
  #
  class Results

    # Duration is set externally by the query.
    #
    attr_writer :duration
    attr_reader :allocations,
                :offset,
                :amount,
                :query

    # Takes instances of Query::Allocations as param.
    #
    def initialize query = nil, amount = 0, offset = 0, allocations = Query::Allocations.new
      @amount      = amount
      @query       = query
      @offset      = offset
      @allocations = allocations
    end

    # Create new results and calculate the ids.
    #
    def self.from query, amount, offset, allocations, extra_allocations = nil
      results = new query, amount, offset, allocations
      results.prepare! extra_allocations
      results
    end

    # This starts the actual processing.
    #
    # Without this, the allocations are not processed,
    # and no ids are calculated.
    #
    def prepare! extra_allocations = nil
      allocations.process! amount, offset, extra_allocations
    end

    # Delegates to allocations.
    #
    def ids amount = 20
      allocations.ids amount
    end

    # The total results. Delegates to the allocations.
    #
    def total
      @total || @total = allocations.total || 0
    end

    # Duration default is 0.
    #
    def duration
      @duration || 0
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

    # For logging.
    #
    def to_s
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