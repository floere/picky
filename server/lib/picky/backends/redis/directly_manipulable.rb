module Picky

  module Backends

    class Redis

      module DirectlyManipulable

        attr_accessor :backend, :key

        def self.make backend, list, key
          list.extend DirectlyManipulable
          list.backend = backend
          list.key     = key
          list
        end

        # TODO Current implementation does not keep order.
        #
        def << value
          super value
          backend.client.zadd "#{backend.namespace}:#{key}", :'0', value
          backend[key]
        end

        # TODO Current implementation does not keep order.
        #
        def unshift value
          super value
          backend.client.zadd "#{backend.namespace}:#{key}", :'0', value
          backend[key]
        end

        def delete value
          result = super value
          if result
            backend.client.zrem "#{backend.namespace}:#{key}", value # TODO if super(value) ?
          end
          result
        end
      end

    end

  end

end