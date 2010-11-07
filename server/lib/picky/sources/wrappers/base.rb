module Sources
  
  module Wrappers
    
    class Base
      
      attr_reader :backend
      
      # Wraps a backend
      #
      def initialize backend
        @backend = backend
      end
      
      # Default is delegation for all methods
      #
      delegate :harvest, :connect_backend, :take_snapshot, :to => :backend
      
    end
      
  end
  
end