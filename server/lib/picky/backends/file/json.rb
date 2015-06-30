module Picky

  module Backends

    class File
      
      def json *args
        JSON.new *args
      end

      # File-based index files dumped in the JSON format.
      #
      class JSON < Basic

        attr_writer :mapping

        # The in-memory mapping hash, mapping
        # a Symbol key to [length, offset] of
        # the JSON data in the file.
        #
        def mapping
          @mapping || raise("The File index/category needs to be loaded first.")
        end

        # See lib/picky/backends/file.rb for what this should return.
        #
        # 1. Gets the length and offset for the key.
        # 2. Extracts and decodes the object from the file.
        #
        def [] key
          length, offset = mapping[key]
          return unless length
          result = MultiJson.decode IO.read(cache_path, length, offset)
          result
        end

        # Clears the currently loaded index.
        #
        # Note: This only clears the in-memory mapping,
        #       but this is enough for the index to not exist
        #       anymore, at least to the application.
        #
        def clear
          self.mapping.clear
        end

        # Size of the index is equal to the mapping size.
        #
        def size
          self.mapping.size
        end

        # Loads the mapping hash from json format.
        #
        def load symbol_keys
          self.mapping = mapping_file.load symbol_keys
          self
        end

        # Dumps the index hash in json format.
        #
        # 1. Dump actual data.
        # 2. Dumps mapping key => [length, offset].
        #
        def dump hash
          offset = 0
          mapping = Hash.new
          
          create_directory cache_path
          ::File.open(cache_path, 'w:utf-8') do |out_file|
            hash.each do |(key, object)|
              encoded = MultiJson.encode object
              length  = encoded.size
              mapping[key] = [length, offset]
              offset += length
              out_file.write encoded
            end
          end

          mapping_file.dump mapping
        end

        # A json file does not provide retrieve functionality.
        #
        def retrieve
          raise "Can't retrieve from JSON file. Use text file."
        end

        # Uses the extension "json".
        #
        def extension
          :json
        end

      end

    end

  end

end
