# encoding: utf-8
#
module Picky

  module Indexed # :nodoc:all

    # TODO Replace inheritance by passing in the backend. Before that, unify the backend interface.
    #
    module Bundle

      # This is the _actual_ index (based on memory).
      #
      # Handles exact/partial index, weights index, and similarity index.
      #
      # Delegates file handling and checking to an *Indexed*::*Files* object.
      #
      class Memory < Base

        def initialize name, category, *args
          super name, category, *args

          @backend = Backend::Files.new self # TODO Rename to Memory and push functionality there.
        end

      end

    end

  end

end