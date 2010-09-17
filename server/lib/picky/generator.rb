module Picky
  
  class NoGeneratorException < Exception; end
  
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
    def generate args
      generator = generator_for *args
      generator.generate
    end
    
    #
    #
    def generator_for identifier, *args
      generator_class = types[identifier.to_sym]
      raise NoGeneratorException unless generator_class
      generator_class.new *args
    end
    
    class Project
      
      attr_reader :name, :prototype_project_basedir
      
      def initialize name, *args
        @name = name
        @prototype_project_basedir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'prototype_project'))
      end
      
      #
      #
      def generate
        target = File.expand_path File.join(Dir.pwd, name)
        FileUtils.cp_r prototype_project_basedir, target, :verbose => true
      end
      
    end
    
  end
  
end