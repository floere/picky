module Picky

  module Backends

    class File

      # Base class for all file-based index files.
      #
      # Provides necessary helper methods for its
      # subclasses.
      # Not directly useable, as it does not provide
      # dump/load methods.
      #
      class Basic

        include Helpers::File

        attr_reader :cache_path,  # This index file's location.
                    :mapping_file # The index file's mapping file (loaded into memory for quick access).

        # An index cache takes a path, without file extension,
        # which will be provided by the subclasses.
        #
        def initialize cache_path
          @cache_path = "#{cache_path}.file.#{extension}"

          # This is the mapping file with the in-memory hash for the
          # file position/offset mappings.
          #
          @mapping_file = Memory::JSON.new "#{cache_path}.file_mapping.#{extension}"
        end

        # The initial content before loading.
        #
        def default
          nil
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
          mapping_file.backup

          prepare_backup backup_directory(cache_path)
          FileUtils.cp cache_path, target, verbose: true
        end

        # Copies the file from its backup location back
        # to the original location.
        #
        def restore
          mapping_file.restore

          FileUtils.cp backup_file_path_of(cache_path), cache_path, verbose: true
        end

        # Deletes the file.
        #
        def delete
          mapping_file.delete

          `rm -Rf #{cache_path}`
        end

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

      end

    end

  end

end