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
        def load
          ::Marshal.load ::File.open(cache_path, 'r:binary')
        end

        # Dumps the index internal backend in marshal format.
        #
        def dump internal, io = nil
          create_directory cache_path
          if io
            dump_marshal internal, io
          else
            ::File.open(cache_path, 'w:binary') do |out_file|
              dump_marshal internal, out_file
            end
          end
        end

        # Dumps binary self to the path given. Minus extension.
        #
        def dump_marshal internal, io
          ::Marshal.dump internal, io
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