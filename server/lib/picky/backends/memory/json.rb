module Picky

  module Backends

    class Memory
      
      def json *args
        JSON.new *args
      end

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
        # Also ensures all hash keys are frozen.
        #
        def load
          MultiJson.decode ::File.open(cache_path, 'r') # , symbolize_keys: true # SYMBOLS.
          # index_hash && index_hash.each { |(key, value)| key.freeze }
          # index_hash
        end

        # Dumps the index internal backend in json format.
        #
        def dump internal, io = nil
          if io
            dump_json internal, io
          else
            create_directory cache_path
            ::File.open(cache_path, 'w') do |out_file|
              # If using Yajl, this will stream write to out_file.
              # Note: But it fails on oj.
              #
              # MultiJson.dump internal, [out_file]
              dump_json internal, out_file
            end
          end
        end

        # Dump JSON into the cache file.
        #
        # TODO Add IO option:
        # MultiJson.encode(object, io: out_file)
        #
        def dump_json internal, io
          io.write MultiJson.encode internal
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