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
        
        # What hash type to use. Default: ::Hash
        #
        attr_reader :hash_type

        # An index cache takes a path, without file extension,
        # which will be provided by the subclasses.
        #
        def initialize cache_path, hash_type = Hash, options = {}
          @cache_path = "#{cache_path}.memory.#{extension}"
          @hash_type  = hash_type
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
          @empty && @empty.clone || hash_type.new
        end
        
        def empty_hash
          # TODO Make this an explicit option.
          if defined? GoogleHashSparseRubyToRuby
            GoogleHashSparseRubyToRuby.new # TODO Use GoogleHashDenseIntToRuby where possible.
          else
            {}
          end
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