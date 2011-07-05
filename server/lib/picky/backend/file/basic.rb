module Backend

  # Handles all aspects of index files, such as dumping/loading.
  #
  module File

    # Base class for all index files.
    #
    # Provides necessary helper methods for its
    # subclasses.
    # Not directly useable, as it does not provide
    # dump/load methods.
    #
    class Basic

      # This file's location.
      #
      attr_reader :cache_path

      # An index cache takes a path, without file extension,
      # which will be provided by the subclasses.
      #
      def initialize cache_path
        @cache_path = "#{cache_path}.#{extension}"
      end

      # The default extension for index files is "index".
      #
      def extension
        :index
      end

      # Will copy the index file to a location that
      # is in a directory named "backup" right under
      # the directory the index file is in.
      #
      def backup
        prepare_backup backup_directory
        FileUtils.cp cache_path, target, verbose: true
      end

      # The backup directory of this file.
      # Equal to the file's dirname plus /backup
      #

      def backup_directory
        ::File.join ::File.dirname(cache_path), 'backup'
      end

      # Prepares the backup directory for the file.
      #
      def prepare_backup target
        FileUtils.mkdir target unless Dir.exists?(target)
      end

      # Copies the file from its backup location back
      # to the original location.
      #
      def restore
        FileUtils.cp backup_file_path_of(cache_path), cache_path, verbose: true
      end

      # The backup filename.
      #
      def backup_file_path_of path
        dir, name = ::File.split path
        ::File.join dir, 'backup', name
      end

      # Deletes the file.
      #
      def delete
        `rm -Rf #{cache_path}`
      end

      # Checks.
      #

      # Is this cache file suspiciously small?
      # (less than 8 Bytes of size)
      #
      def cache_small?
        size_of(cache_path) < 8
      end
      # Is the cache ok? (existing and larger than
      # zero Bytes in size)
      #
      # A small cache is still ok.
      #
      def cache_ok?
        size_of(cache_path) > 0
      end
      # Extracts the size of the file in Bytes.
      #
      def size_of path
        `ls -l #{path} | awk '{print $5}'`.to_i
      end

      #
      #
      def to_s
        "#{self.class}(#{cache_path})"
      end

    end

  end

end