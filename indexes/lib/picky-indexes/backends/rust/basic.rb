module Picky

  module Backends

    class Rust

      # Base class for all Rust memory-based index files.
      #
      # Provides necessary helper methods for its
      # subclasses.
      # Not directly useable, as it does not provide
      # dump/load methods.
      #
      class Basic < Memory::Basic

        # An index cache takes a path, without file extension,
        # which will be provided by the subclasses.
        #
        def initialize cache_file_path, hash_type = Hash, options = {}
          super(cache_file_path, Rust::)
        end

        # The default extension for index files is "index".
        #
        def extension
          :index
        end
        def type
          :memory
        end
        def cache_path
          [cache_file_path, type, extension].join(?.)
        end

        # The empty index that is used for putting the index
        # together before it is dumped into the files.
        #
        def empty
          @empty && @empty.clone || hash_type.new
        end

        # The initial content before loading from file/indexing.
        #
        def initial
          @initial && @initial.clone || hash_type.new
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