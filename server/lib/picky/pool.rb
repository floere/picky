module Picky

  # Module that handles object pool behaviour
  # for you.
  #
  module Pool
    
    class << self
      
      # Installs itself on a few internal classes.
      #
      # Note: If you need to run two consecutive queries,
      # this can't be used.
      #
      # Note: You need to call Picky::Pool.release_all after each query
      # (or after a few queries).
      #
      def install
        Query::Token.extend self
        Query::Tokens.extend self
        Query::Combination.extend self
        Query::Combinations.extend self
        Query::Allocation.extend self
        Query::Allocations.extend self
      end
      
      # Initialise/Reset the pool.
      #
      def clear
        require 'set'
        @pools = Set.new
      end
      
      # Add a pooled class to the managed pools.
      #
      def add klass
        @pools << klass
      end
      
      # Releases all obtained objects.
      #
      def release_all
        @pools.each { |pool| pool.release_all }
      end
      
    end
    
    # Reset the pool.
    #
    self.clear
    
    def self.extended klass
      add klass
      
      class << klass
        
        # Initialise/Reset the class pool.
        #
        def clear
          @__free__ = []
          @__used__ = []
        end
           
        # Obtain creates a new reference if there is no free one
        # and uses an existing one if there is.
        #
        def new *args, &block
          unless reference = @__free__.shift
            reference = allocate
          end
          reference.send :initialize, *args, &block
          @__used__ << reference
          reference
        end
      
        # Releasing an instance adds it to the free pool.
        # (And removes it from the used pool)
        #
        def release instance
          @__free__ << instance
           
          # Note: This is relatively fast as there are often only
          # few instances in the used pool.
          #
          @__used__.delete instance 
        end
      
        # After you have called release all, you can't externally
        # use any reference that has formerly been obtained
        # anymore.
        #
        def release_all
          @__used__.each { |used| @__free__ << used } # +0 Array per release_all
          # @__used__ += @__free__ # +1 Array per release_all
          @__used__.clear
        end
      
        # How many obtainable objects are there?
        #
        def free_size
          @__free__.size
        end
      
        # How many used objects are there?
        #
        def used_size
          @__used__.size
        end
      end
      
      # Initialize the pool.
      #
      klass.clear
    
      # Pooled objects can be released using
      #   object.release
      #
      # Note: Do not use the object in any form after the release.
      #
      klass.send :define_method, :release do
        klass.release self
      end
      
    end
    
  end
  
end