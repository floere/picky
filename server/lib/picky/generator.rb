module Picky
  
  # This is a very simple project generator.
  # Not at all like Padrino's or Rails'.
  # (No diss, just by way of a faster explanation)
  #
  # Basically copies a prototype project into a newly generated directory.
  #
  class Generator
    
    attr_reader :types
    
    def initialize
      @types = {
        :project => Project
      }
    end
    
    # Run the generators with this command.
    #
    # This will "route" the commands to the right specific generator.
    #
    def run args
      type = args.shift
      generator_class = types[type.to_sym]
      
      # TODO Explain why not here.
      return unless generator_class
      
      generator = generator_class.new *args
      generator.run
    end
    
    class Project
      
      attr_reader :name
      
      def initialize name, *args
        @name = name
      end
      
      def run
        p "Doing something with #{name}"
      end
      
    end
    
  end
  
end