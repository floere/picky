module Picky

  module Backends

    class Memory

      # Memory-based index files dumped in the JSON format.
      #
      class JSON < Basic

        # Uses the extension "json".
        #
        def extension
          :json
        end

        # Loads the index hash from json format.
        #
        def load
          Yajl::Parser.parse ::File.open(cache_path, 'r') # , symbolize_keys: true # TODO Symbols.
        end

        # Dumps the index internal backend in json format.
        #
        def dump internal
          create_directory cache_path
          dump_json internal
        end

        #
        #
        def dump_json internal
          ::File.open(cache_path, 'w') do |out_file|
            #Yajl::Encoder.encode internal, out_file
            out_file.write (Yajl::Encoder.encode internal) 
          end
        end

        # A json file does not provide retrieve functionality.
        #
        def retrieve
          raise "Can't retrieve from JSON file. Use text file."
        end

      end

    end

  end

end
