module Picky

  module Backends

    class Prepared

      # Index data dumped in the text format.
      #
      class Text

        include Helpers::File

        attr_reader :cache_path

        def initialize cache_path, options = {}
          @cache_path = "#{cache_path}.prepared.#{extension}"
        end

        # Uses the extension "txt".
        #
        def extension
          :txt
        end

        # The initial content before loading.
        #
        def initial
          raise "Can't have an initial content from text file. Use JSON or Marshal."
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
        # Yields an id string and a token.
        #
        # TODO Think about the comma - what if you have commas in the id? Use CSV?
        #
        def retrieve
          id    = nil
          token = nil
          ::File.open(cache_path, 'r:utf-8') do |file|
            file.each_line do |line|
              id, token = line.split ?,, 2
              yield id.freeze, (token.chomp! || token).freeze
            end
          end
        end

        #
        #
        def open &block
          create_directory cache_path
          ::File.open cache_path, 'w:utf-8', &block
        end


      end

    end

  end

end