module Picky

  # Module that handles object pool behaviour
  # for you.
  #
  module Pool
    
    def self.extended klass
      
      def Obj.obtain *args, &block
        @@__references__.shift || Obj.new(*args, &block)
      end
    
      def Obj.release instance
         @@__references__ << instance
      end
    
      def release
        Obj.release self
      end
      
    end
    
  end
  
end