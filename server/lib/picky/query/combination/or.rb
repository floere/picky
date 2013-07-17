module Picky

  module Query

    class Combination
      
      # Pretends to be a combination.
      #
      # TODO Rework completely and document.
      #
      class Or < Combination
        
        def initialize combinations
          @combinations = combinations
        end
        
        # Returns the combination's category name.
        # Used in boosting.
        #
        def category_name
          @category_name ||= @combinations.map(&:category_name).join('|').intern
        end

        # Returns the total (?) weight of its combinations.
        #
        # Note: Caching is most of the time useful.
        #
        def weight
          @weight ||= @combinations.inject(0) do |sum, combination|
            sum + combination.weight
          end
        end

        # Returns an array of ids from its combinations.
        #
        # Note: Caching is most of the time useful.
        #
        def ids
          @ids ||= @combinations.inject([]) do |total, combination|
            total + combination.ids
          end.uniq
        end
        
        def identifier
          @identifier ||= "#{@combinations.map(&:bundle).map(&:identifier).join('|')}:inverted:#{token.text}"
        end
        
        def to_result
          results = @combinations.map &:to_result
          [*@combinations.map(&:to_result).transpose.map! { |thing| thing.join('|') }]
        end
        
      end
      
    end
    
  end
  
end