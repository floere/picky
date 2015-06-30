module Picky

  module Backends

    class Redis

      # Redis Backend Accessor.
      #
      # Provides necessary helper methods for its
      # subclasses.
      # Not directly useable, as it does not provide
      # dump/load methods.
      #
      class Basic

        attr_reader :client, :namespace

        # An index cache takes a path, without file extension,
        # which will be provided by the subclasses.
        #
        def initialize client, namespace, options = {}
          @client    = client
          @namespace = namespace

          @empty    = options[:empty]
          @initial  = options[:initial]
          @realtime = options[:realtime]
        end

        # The empty index that is used for putting the index
        # together.
        #
        def empty
          @empty && @empty.clone || (@realtime ? self.reset : {})
        end

        # The initial content before loading.
        #
        # Note: As Redis indexes needn't be loaded per se,
        #       this just returns the same thing as #load.
        #
        def initial
          @initial && @initial.clone || (@realtime ? self.reset : {})
        end

        # Returns itself.
        #
        def load _
          self
        end

        # We do not use Redis to retrieve data.
        #
        def retrieve
          # Nothing.
        end

        # Clears the whole namespace.
        #
        def reset
          clear
          self
        end

        #
        #
        def to_s
          "#{self.class}(#{namespace}:*)"
        end

      end

    end

  end

end