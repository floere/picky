module Picky
  module Model

    #
    #
    module Searching

      #
      #
      def self.included into
        into.extend ClassMethods
      end

      #
      #
      class Proxy

        # Initialize with defaults.
        #
        def initialize model
          @model   = model
          @text    = nil
          @indexes = model.__picky_default_indexes__
          @ids     = 20
          @offset  = 0
        end

        #
        #
        # Usage:
        #  * Person.search("Bond, James")              # Convenience version.
        #  * Person.search.ids(30).with("Bond, James") # Version with options.
        #  * Person.search("Bond, James") do           # With block.
        #      ids 30
        #      offset 10
        #    end
        #
        def search text = nil, options = {}, &block
          instance_eval(&block) if block_given?

          if text
            #
            #
            with text
          else
            # The user wants the proxy.
            # (Or made the mistake of passing nil)
            #
            self
          end
        end

        #
        #
        def with text
          @text = text
          p "Searching in #{@indexes} with offset #{@offset} and for #{@ids} ids with '#{@text}'"
        end

        # Define which indexes to use.
        #
        def indexes index, *indexes
          @indexes = [index, *indexes]
          self
        end

        #
        #
        def ids value
          @ids = value
          self
        end

        # Set an offset for this search.
        #
        def offset value
          @offset = value
          self
        end

      end

      module ClassMethods

        #
        #
        def self.extended into
          into.extend Convenience unless into.respond_to?(:search)
        end

        # This is the method that is called by the convenience methods.
        #
        # It returns a Proxy instance on which to search on.
        #
        # So if you defined
        #
        def picky
          (@proxy ||= Proxy.new(self)).dup
        end

        #
        #
        module Convenience

          #
          #
          def search text = nil, options = {}, &block
            picky.search text, options, &block
          end

        end

      end

    end

  end
end

class Bla

  include Picky::Model::Searching

  # Fake method since indexing has not yet been coded.
  #
  def self.__picky_default_indexes__
    [:blas]
  end

end

Bla.picky.search("hello")
Bla.picky.search.with("hello")
Bla.picky.search.offset(30).with("hello")
Bla.picky.search.indexes(:blis).ids(30).offset(10).with("hello")

Bla.search("hello")
Bla.search.with("hello")
Bla.search.offset(30).with("hello")
Bla.search.indexes(:blis).ids(30).offset(10).with("hello")
Bla.search "Gurrr" do
  indexes :blooo
  ids     77
  offset  13
end