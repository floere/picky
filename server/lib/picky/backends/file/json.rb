module Picky

  module Backends

    class File

      # File-based index files dumped in the JSON format.
      #
      class JSON < Basic

        attr_accessor :mapping

        # Uses the extension "json".
        #
        def extension
          :json
        end

        #
        #
        # 1. Gets the length and offset for the key.
        # 2. Extracts and decodes the object from the file.
        #
        def [] key
          length, offset = mapping[key]
          return [] unless length
          result = Yajl::Parser.parse IO.read(cache_path, length, offset)
          result
        end

        # Clears the currently loaded index.
        #
        def clear
          self.mapping.clear
        end

        # Loads the mapping hash from json format.
        #
        def load
          self.mapping = mapping_file.load
          self
        end

        # Dumps the index hash in json format.
        #
        # 1. Dump actual data.
        # 2. Dumps mapping key => [length, offset].
        #
        def dump hash
          offset = 0
          mapping = {}

          ::File.open(cache_path, 'w:utf-8') do |out_file|
            hash.each do |(key, object)|
              encoded = Yajl::Encoder.encode object
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

      end

    end

  end

end