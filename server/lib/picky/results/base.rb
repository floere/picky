module Results

  # This is the internal results object. Usually, to_marshal, or to_json
  # is called on it to get a string for the answer.
  #
  class Base

    # Duration is set externally by the query.
    #
    attr_writer :duration
    attr_reader :allocations, :offset

    # Takes instances of Query::Allocations as param.
    #
    def initialize offset = 0, allocations = nil
      @offset = offset
      @allocations = allocations || Query::Allocations.new
    end

    #
    #
    def serialize
      { allocations: allocations.to_result,
        offset:      offset,
        duration:    duration,
        total:       total }
    end
    # The default format is json.
    #
    def to_response options = {}
      to_json options
    end
    # Convert to json format.
    #
    def to_json options = {}
      serialize.to_json options
    end

    # This starts the actual processing.
    #
    # Without this, the allocations are not processed,
    # and no ids are calculated.
    #
    def prepare!
      allocations.process! self.max_results, self.offset
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

    # How many results are returned.
    #
    # Set in config using
    #   Results::Full.max_results = 20
    #
    class_inheritable_accessor :max_results
    def max_results
      self.class.max_results
    end

    # Convenience methods.
    #

    # Delegates to allocations.
    #
    def ids amount = 20
      allocations.ids amount
    end
    # Gets an amout of random ids from the allocations.
    #
    # Note: Basically delegates to the allocations.
    #
    def random_ids amount = 1
      allocations.random_ids amount
    end

    # Human readable log.
    #
    def to_log query
      "|#{Time.now.to_s(:db)}|#{'%8f' % duration}|#{'%-50s' % query}|#{'%8d' % total}|#{'%4d' % offset}|#{'%2d' % allocations.size}|"
    end
    
  end

end