module Picky

  module Backend

    class Redis

      # Redis Backend Accessor.
      #
      # Provides necessary helper methods for its
      # subclasses.
      # Not directly useable, as it does not provide
      # dump/load methods.
      #
      class Basic

        attr_reader :namespace, :backend

        # An index cache takes a path, without file extension,
        # which will be provided by the subclasses.
        #
        def initialize namespace
          @namespace = namespace

          # TODO Turn this inside out such that people can pass in
          # their own Redis instance.
          #
          # TODO Make the :db a real option.
          #
          @backend = ::Redis.new :db => 15
        end

        # Returns itself.
        #
        def load
          self
        end

        # We do not use Redis to retrieve data.
        #
        def retrieve
          # Nothing.
        end

        # Redis doesn't do backup.
        #
        def backup
          # Nothing.
        end

        # Deletes the Redis index namespace.
        #
        def delete
          # Not implemented here.
          # Note: backend.flushdb might be the way to go,
          #       but since we cannot delete by key pattern,
          #       we don't do anything.
        end

        # Checks.
        #

        # Is this cache suspiciously small?
        #
        def cache_small?
          size < 1
        end

        # Is the cache ok?
        #
        # A small cache is still ok.
        #
        def cache_ok?
          size > 0
        end

        # Extracts the size of the file in Bytes.
        #
        # Note: This is a very forgiving implementation.
        #       But as long as Redis does not implement
        #       DBSIZE KEYPATTERN, we are stuck with this.
        #
        def size
          backend.dbsize
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