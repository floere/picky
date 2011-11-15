module Picky

  module Backends

    class Memory

      # Base class for all memory-based index files.
      #
      # Provides necessary helper methods for its
      # subclasses.
      # Not directly useable, as it does not provide
      # dump/load methods.
      #
      class Basic

        include Helpers::File

        # This file's location.
        #
        attr_reader :cache_path

        # An index cache takes a path, without file extension,
        # which will be provided by the subclasses.
        #
        def initialize cache_path, options = {}
          @cache_path = "#{cache_path}.memory.#{extension}"
          @empty      = options[:empty]
          @initial    = options[:initial]
        end

        # The default extension for index files is "index".
        #
        def extension
          :index
        end

        # The empty index that is used for putting the index
        # together before it is dumped into the files.
        #
        def empty
          @empty && @empty.clone || {}
        end

        # The initial content before loading from file.
        #
        def initial
          @initial && @initial.clone || {}
        end

        # Deletes the file.
        #
        def delete
          `rm -Rf #{cache_path}`
        end

        #
        #
        def to_s
          "#{self.class}(#{cache_path})"
        end

      end

    end

  end

end