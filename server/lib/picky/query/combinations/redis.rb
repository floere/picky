module Query

  # Combinations are a number of Combination-s.
  #
  # They are the core of an allocation.
  # An allocation consists of a number of combinations.
  #
  module Combinations # :nodoc:all
    
    # Redis Combinations contain specific methods for
    # calculating score and ids in memory.
    #
    class Redis < Base
      
      # TODO Err… yeah. Wrap in Picky specific wrapper.
      #
      def initialize combinations
        super combinations
        
        @@redis ||= ::Redis.new
      end
      
      # Returns the result ids for the allocation.
      #
      def ids amount, offset
        return [] if @combinations.empty?
        
        identifiers = @combinations.inject([]) do |identifiers, combination|
          identifiers << "#{combination.identifier}"
        end
        
        result_id = generate_intermediate_result_id
        
        # TODO multi?
        #
        
        @@redis.zinterstore result_id, identifiers
        
        @@redis.zrange result_id, offset, (offset + amount)
      end
      
      # Generate a multiple host/process safe result id.
      #
      # TODO How expensive is Process.pid? If it changes once, remember forever?
      #
      def generate_intermediate_result_id
        # TODO host -> extract host.
        :"host:#{Process.pid}:picky:result"
      end
      
    end
    
  end
  
end