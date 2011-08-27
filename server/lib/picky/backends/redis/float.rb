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
        def [] key
          super.to_f
        end

      end

    end

  end

end