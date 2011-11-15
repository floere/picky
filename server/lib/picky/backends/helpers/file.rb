module Picky

  module Backends

    module Helpers

      # Common file helpers.
      #
      module File

        # Creates all necessary directories.
        #
        def create_directory path
          FileUtils.mkdir_p ::File.dirname(path)
        end

      end

    end

  end

end