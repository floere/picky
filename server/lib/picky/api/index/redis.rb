module API
  module Index
    class Redis < Base
      
      # Injects the necessary options & configurations for
      # a Redis index backend.
      #
      def initialize name, source, options = {}
        options[:bundle_class] ||= Indexed::Bundle::Redis
        
        super name, source, options
      end
      
    end
  end
end