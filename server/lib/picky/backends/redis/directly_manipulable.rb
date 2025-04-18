module Picky
  module Backends
    class Redis
      module DirectlyManipulable
        mattr_accessor :append_index
        self.append_index = 0

        mattr_accessor :unshift_index
        self.unshift_index = 0

        attr_accessor :backend, :key

        def self.make(backend, list, key)
          list.extend DirectlyManipulable
          list.backend = backend
          list.key     = key
        end

        # THINK Current implementation is very brittle.
        #
        def <<(value)
          super
          zadd value, DirectlyManipulable.append_index += 1
        end

        # THINK Current implementation is very brittle.
        #
        def unshift(value)
          super
          zadd value, DirectlyManipulable.unshift_index -= 1
        end

        # Deletes the value.
        #
        def delete(value)
          result = super value
          backend.client.zrem "#{backend.namespace}:#{key}", value if result
          result
        end

        # Z-Adds a value with the given index.
        #
        def zadd(value, index)
          backend.client.zadd "#{backend.namespace}:#{key}", index, value
          backend[key]
        end
      end
    end
  end
end
