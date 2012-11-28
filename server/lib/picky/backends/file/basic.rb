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
        def initialize cache_path, options = {}
          @cache_path = "#{cache_path}.file.#{extension}"

          # This is the mapping file with the in-memory hash for the
          # file position/offset mappings.
          #
          @mapping_file = Memory::JSON.new "#{cache_path}.file_mapping"

          @empty   = options[:empty]
          @initial = options[:initial]
        end

        # The default extension for index files is "index".
        #
        def extension
          :index
        end

        # The empty index that is used for putting the index
        # together before it is saved into the files.
        #
        def empty
          @empty && @empty.clone || {}
        end

        # The initial content before loading.
        #
        # Note: We could also load the mapping file
        #       as in #load.
        #
        def initial
          @initial && @initial.clone || {}
        end

        # Deletes the file.
        #
        def delete
          mapping_file.delete

          `rm -Rf #{cache_path}`
        end

        #
        #
        def to_s
          "#{self.class}(#{cache_path},#{mapping_file.cache_path})"
        end

      end

    end

  end

end