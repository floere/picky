module Picky

  module Backends

    class Memory

      # Index data in the Ruby Marshal format.
      #
      class Marshal < Basic

        # Uses the extension "dump".
        #
        def extension
          :dump
        end

        # Loads the index hash from marshal format.
        #
        def load _
          ::Marshal.load ::File.open(cache_path, 'r:binary')
        end

        # Dumps the index internal backend in marshal format.
        #
        def dump internal
          create_directory cache_path
          dump_marshal internal
        end

        # Dumps binary self to the path given. Minus extension.
        #
        def dump_marshal internal
          ::File.open(cache_path, 'w:binary') do |out_file|
            ::Marshal.dump internal, out_file
          end
        end

        # A marshal file does not provide retrieve functionality.
        #
        def retrieve
          raise "Can't retrieve from marshalled file. Use text file."
        end

      end

    end

  end

end