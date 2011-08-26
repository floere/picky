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

        # This file's location.
        #
        attr_reader :cache_path,
                    :mapping_file

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

        # The default extension for index files is "index".
        #
        def extension
          :index
        end

      end

    end

  end

end