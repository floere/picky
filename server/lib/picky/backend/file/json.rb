module Picky

  module Backend

    module File

      # Index files dumped in the JSON format.
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
          Yajl::Parser.parse ::File.open(cache_path, 'r'), symbolize_keys: true

          # Note: Circumvents the yajl symbolize utf-8 characters problem.
          #
          # Yajl::Parser.parse(::File.open(cache_path, 'r')).inject({}) do |hash, (k, v)|
          #   hash[k.to_sym] = v
          #   hash
          # end
        end
        # Dumps the index hash in json format.
        #
        def dump hash
          hash.dump_json cache_path
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