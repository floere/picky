module Picky

  # Module that handles object pool behaviour
  # for you.
  #
  module Pool
    
    class << self
      
      def clear
        require 'set'
        @pools = Set.new
      end
      
      # Add a Pool to the managed pools.
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
        #
        #
        def clear
          @__free__ = []
          @__used__ = []
        end
           
        # Obtain creates a new reference if there is no free one
        # and uses an existing one if there is.
        #
        # (Any caches should be cleared using clear TODO in all initializers)
        #
        def obtain *args, &block
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
           @__used__.delete instance # TODO Optimize
        end
      
        # After you have called release all, you can't
        # use any reference that has formerly been obtained
        # anymore.
        #
        def release_all
          @__used__.each { |used| @__free__ << used } # TODO Optimize
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