module Picky

  module Backends

    class SQLite

      module DirectlyManipulable

        attr_accessor :backend, :key

        def self.make backend, array, key
          array.extend DirectlyManipulable
          array.backend = backend
          array.key     = key
        end

        def << value
          super value
          backend[key] = self
          self
        end

        def unshift value
          super value
          backend[key] = self
          self
        end

        def delete value
          value = super value
          if value
            backend[key] = self
          end
          value
        end
      end

    end

  end

end