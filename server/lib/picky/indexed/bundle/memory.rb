# encoding: utf-8
#
module Picky

  module Indexed # :nodoc:all

    #
    #
    module Bundle

      # This is the _actual_ index (based on memory).
      #
      # Handles exact/partial index, weights index, and similarity index.
      #
      # Delegates file handling and checking to an *Indexed*::*Files* object.
      #
      class Memory < Base

        delegate :[], :to => :configuration

        def initialize name, category, *args
          super name, category, *args

          @configuration = {} # A hash with config options.

          @backend = Backend::Files.new self
        end

        # Get the ids for the given symbol.
        #
        def ids sym
          @inverted[sym] || []
        end
        # Get a weight for the given symbol.
        #
        def weight sym
          @weights[sym]
        end

        # Loads the core index.
        #
        def load_inverted
          self.inverted = @backend.load_inverted
        end
        # Loads the weights index.
        #
        def load_weights
          self.weights = @backend.load_weights
        end
        # Loads the similarity index.
        #
        def load_similarity
          self.similarity = @backend.load_similarity
        end
        # Loads the configuration.
        #
        def load_configuration
          self.configuration = @backend.load_configuration
        end

        # Loads the core index.
        #
        def clear_inverted
          self.inverted = {}
        end
        # Loads the weights index.
        #
        def clear_weights
          self.weights = {}
        end
        # Loads the similarity index.
        #
        def clear_similarity
          self.similarity = {}
        end
        # Loads the configuration.
        #
        def clear_configuration
          self.configuration = {}
        end

      end

    end

  end

end