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
      generator_for_class generator_class, *args
    end
    
    #
    #
    def generator_for_class klass, *args
      klass.new *args
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
        exclaim "Setting up Picky project \"#{name}\"."
        create_target_directory
        copy_all_files
      end
      
      #
      #
      def create_target_directory
        if File.exists?(target_directory)
          exists target_directory
        else
          FileUtils.mkdir target_directory
          created target_directory
        end
      end
      
      #
      #
      def copy_all_files
        all_prototype_files.each do |filename|
          next if filename.match(/\.textile$/)
          copy_single_file filename
        end
      end
      
      #
      #
      def target_filename_for filename
        filename.gsub(%r{#{prototype_project_basedir}}, target_directory)
      end
      #
      #
      def copy_single_file filename
        target = target_filename_for filename
        if File.exists? target
          exists target
        else
          smart_copy filename, target
        end
      end
      
      # Well, "smart" ;)
      #
      def smart_copy filename, target
        # p "Trying to copy #{filename} -> #{target}"
        FileUtils.copy_file filename, target
        created target
      rescue Errno::EISDIR
        # p "EISDIR #{filename} -> #{target}"
        FileUtils.rm target
        FileUtils.mkdir_p target unless Dir.exists?(target)
        created target
      rescue Errno::EEXIST
        # p "EEXIST #{filename} -> #{target}"
        exists target
      rescue Errno::ENOTDIR
        # p "ENOTDIR #{filename} -> #{target}"
        FileUtils.mkdir_p File.dirname(target) rescue nil
        retry
      rescue Errno::ENOENT => e
        # p "ENOENT #{filename} -> #{target}"
        if File.exists? filename
          FileUtils.mkdir_p File.dirname(target)
          retry
        else
          raise e
        end
      end
      
      #
      #
      def all_prototype_files
        Dir[File.join(prototype_project_basedir, '**', '*')]
      end
      
      #
      #
      def target_directory
        File.expand_path File.join(Dir.pwd, name)
      end
      
      def created entry
        exclaim "#{entry} \x1b[32mcreated\x1b[m."
      end
      
      def exists entry
        exclaim "#{entry} \x1b[31mexists\x1b[m, skipping."
      end
      
      def exclaim something
        puts something
      end
      
    end
    
  end
  
end