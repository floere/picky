module Sources
  
  module Wrappers
    
    class Base
      
      attr_reader :backend, :category
      
      # Wraps an indexing category.
      #
      def initialize category
        @category = category
        @backend  = category.source
      end
      
      # Default is delegation for all methods
      #
      delegate :harvest, :connect_backend, :take_snapshot, :to => :backend
      
    end
      
  end
  
end