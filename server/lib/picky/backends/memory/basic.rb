module Picky

  module Backends

    class Memory

      # Base class for all memory-based index files.
      #
      # Provides necessary helper methods for its
      # subclasses.
      # Not directly useable, as it does not provide
      # dump/load methods.
      #
      class Basic

        include Helpers::File

        # This file's location.
        #
        attr_reader :cache_path

        # An index cache takes a path, without file extension,
        # which will be provided by the subclasses.
        #
        def initialize cache_path, options = {}
          @cache_path = "#{cache_path}.memory.#{extension}"
          @empty      = options[:empty]
          @initial    = options[:initial]
        end

        # The default extension for index files is "index".
        #
        def extension
          :index
        end

        # The empty index that is used for putting the index
        # together before it is dumped into the files.
        #
        def empty
          @empty && @empty.clone || {}
        end

        # The initial content before loading from file.
        #
        def initial
          @initial && @initial.clone || {}
        end

        # Will copy the index file to a location that
        # is in a directory named "backup" right under
        # the directory the index file is in.
        #
        def backup
          prepare_backup backup_directory
          FileUtils.cp cache_path, target, verbose: true
        end

        # Copies the file from its backup location back
        # to the original location.
        #
        def restore
          FileUtils.cp backup_file_path_of(cache_path), cache_path, verbose: true
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

        #
        #
        def to_s
          "#{self.class}(#{cache_path})"
        end

      end

    end

  end

end