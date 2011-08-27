module Picky

  module Backends

    class Memory

      # Index data dumped in the text format.
      #
      # TODO Should this really be Memory::Text?
      #
      class Text < Basic

        # Uses the extension "txt".
        #
        def extension
          :txt
        end

        # Text files are used exclusively for
        # prepared data files.
        #
        def load
          raise "Can't load from text file. Use JSON or Marshal."
        end

        # Text files are used exclusively for
        # prepared data files.
        #
        def dump hash
          raise "Can't dump to text file. Use JSON or Marshal."
        end

        # Retrieves prepared index data in the form
        # * id,data\n
        # * id,data\n
        # * id,data\n
        #
        # Yields an id string and a symbol token.
        #
        def retrieve
          id    = nil
          token = nil
          ::File.open(cache_path, 'r:utf-8') do |file|
            file.each_line do |line|
              id, token = line.split ?,, 2
              yield id, (token.chomp! || token).to_sym
            end
          end
        end

        #
        #
        def open &block
          ::File.open cache_path, 'w:utf-8', &block
        end


      end

    end

  end

end