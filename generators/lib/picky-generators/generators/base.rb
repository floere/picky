# encoding: utf-8
#
require 'fileutils'

module Picky
  
  # This is a very simple generator.
  # Not at all like Padrino's or Rails'.
  # (No diss, just by way of a faster explanation)
  #
  # Basically copies a prototype Unicorn into a newly generated directory.
  #
  module Generators # :nodoc:all
    
    # Simple Base generator.
    #
    class Base
      
      attr_reader :identifier, :name, :prototype_basedir
      
      def initialize identifier, name, prototype_path, *args
        @identifier        = identifier
        @name              = name
        @prototype_basedir = File.expand_path "../../../../prototypes/#{prototype_path}", __FILE__
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
      def copy_all_files from = nil
        all_prototype_files(from).each do |filename|
          next if filename.match(/\.textile$/)
          copy_single_file filename
        end
      end

      #
      #
      def target_filename_for filename
        filename.gsub(%r{#{prototype_basedir}}, target_directory)
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
      def all_prototype_files from = nil
        from ||= prototype_basedir
        Dir[File.join(from, '**', '*')]
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