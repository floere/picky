module Picky

  # This is the internal results object. Usually, to_marshal, or to_json
  # is called on it to get a string for the answer.
  #
  class Results

    include Enumerable

    # Duration is set externally by the query.
    #
    attr_writer :duration
    attr_reader :offset,
                :amount,
                :query,
                :sorting

    # Takes instances of Query::Allocations as param.
    #
    def initialize query = nil, amount = 0, offset = 0, allocations = Query::Allocations.new, extra_allocations = nil, unique = false
      @amount      = amount
      @query       = query
      @offset      = offset
      @allocations = allocations
      @extra_allocations = extra_allocations
      @unique      = unique
    end
    
    # Provide a block which
    # accepts a result id.
    #
    def sort_by &sorting
      @sorting = sorting
    end

    def allocations
      prepare! *(@prepared || [@extra_allocations, @unique])
      @allocations
    end

    # This starts the actual processing.
    #
    # Without this, the allocations are not processed,
    # and no ids are calculated.
    #
    def prepare! extra_allocations = nil, unique = false
      return if @prepared == [extra_allocations, unique] # cached?
      @prepared = [extra_allocations, unique] # cache!
      unique ?
        @allocations.process_unique!(amount, offset, extra_allocations, sorting) :
        @allocations.process!(amount, offset, extra_allocations, sorting)
    end

    def each &block
      allocations.each &block
    end

    # Forwards to allocations.
    #
    # Note that this is an expensive call and
    # should not be done repeatedly. Just keep
    # a reference to the result.
    #
    # TODO Rewrite such that this triggers calculation, not prepare!
    #
    def ids only = amount
      allocations.ids only
    end

    # The total results. Forwards to the allocations.
    #
    def total
      @total ||= allocations.total || 0
    end

    # Duration default is 0.
    #
    def duration
      @duration || 0
    end

    # Returns a hash with the allocations, offset, duration and total.
    #
    def to_hash
      {
        allocations: allocations.to_result,
        offset:      offset,
        duration:    duration,
        total:       total
      }
    end

    # Convert to json format.
    #
    def to_json options = {}
      MultiJson.encode to_hash, options
    end

    # For logging.
    #
    @@log_time_format = "%Y-%m-%d %H:%M:%S".freeze
    def to_s
      "#{log_type}|#{Time.now.strftime @@log_time_format}|#{'%8f' % duration}|#{'%-50s' % query}|#{'%8d' % total}|#{'%4d' % offset}|#{'%2d' % allocations.size}|"
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