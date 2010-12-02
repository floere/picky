# encoding: utf-8
#
require 'fileutils'

module Picky
  
  # Thrown when no generator for the command
  #   picky <command> <options>
  # is found.
  #
  class NoGeneratorError < StandardError
    
    def initialize generator
      super usage + possible_commands(generator.types)
    end
    
    def usage
      "\nUsage:\n" +
      "picky <command> <params>\n" +
      ?\n
    end
    
    def possible_commands types
      "Possible commands:\n" +
      types.map do |name, klass_params|
        result = "picky #{name}"
        _, params = *klass_params
        result << ' ' << [*params].map { |param| "<#{param}>" }.join(' ') if params
        result
      end.join(?\n) + ?\n
    end
    
  end
  
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
        project => [Project, :project_name]
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
      generator_info = types[identifier.to_sym]
      raise NoGeneratorError.new(self) unless generator_info
      generator_class = generator_info.first
      generator_for_class generator_class, identifier, *args
    end
    
    #
    #
    def generator_for_class klass, *args
      klass.new *args
    end
    
    # Generates a new Picky project.
    #
    # Example:
    #   > picky project my_lovely_project
    #
    class Project
      
      attr_reader :name, :project_prototype_basedir
      
      def initialize identifier, name, *args
        @name = name
        @project_prototype_basedir = File.expand_path '../../../project_prototype', __FILE__
      end
      
      #
      #
      def generate
        exclaim "Setting up Picky project \"#{name}\"."
        create_target_directory
        copy_all_files
        exclaim "\"#{name}\" is a great project name! Have fun :)\n"
        exclaim ""
        exclaim "Next steps:"
        exclaim "1. cd #{name}"
        exclaim "2. bundle install"
        exclaim "3. rake index"
        exclaim "4. rake start"
        exclaim "5. rake           # (optional) shows you where Picky needs input from you"
        exclaim "                  #            if you want to define your own search."
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
        filename.gsub(%r{#{project_prototype_basedir}}, target_directory)
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
        FileUtils.mkdir_p target unless File.exist?(target)
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
        Dir[File.join(project_prototype_basedir, '**', '*')]
      end
      
      #
      #
      def target_directory
        File.expand_path name, Dir.pwd
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