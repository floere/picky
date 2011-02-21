module API
  module Index
    class Memory < Base
      
      # Injects the necessary options & configurations for
      # a memory index backend.
      #
      def initialize name, source, options = {}
        options[:bundle_class] ||= Indexed::Bundle::Memory
        
        super name, source, options
      end
      
    end
  end
end