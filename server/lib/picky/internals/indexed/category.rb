module Internals

  module Indexed

    # An index category holds a exact and a partial index for a given category.
    #
    # For example an index category for names holds a exact and
    # a partial index bundle for names.
    #
    class Category

      include Internals::Shared::Category

      attr_accessor :exact
      attr_reader   :name, :index
      attr_writer   :partial

      #
      #
      def initialize name, index, options = {}
        @name  = name
        @index = index

        # TODO Push the defaults out into the index.
        #
        @partial_strategy = options[:partial] || Internals::Generators::Partial::Default
        similarity = options[:similarity] || Internals::Generators::Similarity::Default

        bundle_class = options[:indexed_bundle_class] || Bundle::Memory
        @exact   = bundle_class.new :exact,   self, similarity
        @partial = bundle_class.new :partial, self, similarity

        # @exact   = exact_lambda.call(@exact, @partial)   if exact_lambda   = options[:exact_lambda]
        # @partial = partial_lambda.call(@exact, @partial) if partial_lambda = options[:partial_lambda]

        # TODO Extract?
        #
        Query::Qualifiers.add(name, generate_qualifiers_from(options) || [name])
      end

      def to_s
<<-CATEGORY
Category(#{name}):
  Exact:
#{exact.indented_to_s(4)}
  Partial:
#{partial.indented_to_s(4)}
CATEGORY
      end

      # TODO Move to Index.
      #
      def generate_qualifiers_from options
        options[:qualifiers] || options[:qualifier] && [options[:qualifier]]
      end

      # Loads the index from cache.
      #
      def load_from_cache
        timed_exclaim %Q{"#{identifier}": Loading index.}
        exact.load
        partial.load
      end

      # Loads, analyzes, and clears the index.
      #
      # Note: The idea is not to run this while the search engine is running.
      #
      def analyze collector
        collector[identifier] = {
          :exact   => Analyzer.new.analyze(exact),
          :partial => Analyzer.new.analyze(partial)
        }
        collector
      end

      # Gets the weight for this token's text.
      #
      def weight token
        bundle_for(token).weight token.text
      end

      # Gets the ids for this token's text.
      #
      def ids token
        bundle_for(token).ids token.text
      end

      # Returns the right index bundle for this token.
      #
      def bundle_for token
        token.partial?? partial : exact
      end

      # The partial strategy defines whether to really use the partial index.
      #
      def partial
        @partial_strategy.use_exact_for_partial?? @exact : @partial
      end

      #
      #
      def combination_for token
        weight(token) && Internals::Query::Combination.new(token, self)
      end

    end

  end

end