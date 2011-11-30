# encoding: utf-8
#
module Picky

  module Wrappers

    module Category

      # This index combines an exact and partial index.
      # It serves to order the results such that exact hits are found first.
      #
      class ExactFirst

        delegate :add,
                 :qualifiers,
                 :exact,
                 :partial,
                 :replace,

                 :identifier,
                 :name,

                 :index,
                 :category,
                 :dump,
                 :load,

                 :bundle_for,
                 :build_realtime_mapping,

                 :to => :@category

        def initialize category
          @category = category
          @exact   = category.exact
          @partial = category.partial
        end

        def self.wrap index_or_category
          if index_or_category.respond_to? :categories
            wrap_each_of index_or_category.categories
            index_or_category
          else
            new index_or_category
          end
        end
        def self.wrap_each_of categories
          actual_categories = categories.categories
          categories.clear_categories

          actual_categories.each do |category|
            categories << new(category)
          end
        end

        def ids token
          text = token.text
          if token.partial?
            @exact.ids(text) | @partial.ids(text)
          else
            @exact.ids text
          end
        end

        def weight token
          text = token.text
          if token.partial?
            [@exact.weight(text), @partial.weight(text)].compact.max
          else
            @exact.weight text
          end
        end

        # TODO Refactor! (Subclass Picky::Category?)
        #
        def combination_for token
          weight(token) && Query::Combination.new(token, self)
        end

      end

    end

  end

end