module Picky

  module Backends

    class Redis

      class Float < String

        # Get a single value.
        #
        # Internal API method for the index.
        #
        # Note: Works like the StringHash method, but
        # returns a float corresponding to that string.
        #
        # Note: nil.to_f returns 0.0. That's why the
        #       code below looks a bit funny.
        #
        def [] key
          float = super
          float && float.to_f
        end

      end

    end

  end

end