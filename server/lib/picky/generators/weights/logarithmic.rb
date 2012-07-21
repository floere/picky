module Picky

  module Generators

    module Weights
      
      # Uses a logarithmic weight.
      #
      # If given a constant, this will be added to the weight.
      #
      # If for a key k we have x ids, the weight is:
      # w(x): log(x)
      # Special case: If x < 1, then we use 0.
      #
      class Logarithmic < Strategy
        
        def initialize constant = 0.0
          @constant = constant
          # # Note: Optimisation since it is called
          # # once per indexed object.
          # #
          # if constant == 0.0
          #   install_without_constant
          # else
          #   @constant = constant
          #   install_with_constant
          # end
        end
        
        def weight_for amount
          return @constant if amount < 1
          @constant + Math.log(amount).round(3)
        end
        
        # def install_with_constant
        #   # Sets the weight value.
        #   #
        #   # If the size is 0 or one, we would get -Infinity or 0.0.
        #   # Thus we do not set a value if there is just one. The default, dynamically, is 0.
        #   #
        #   # BUT: We need the value, even if 0. To designate that there IS a weight!
        #   #
        #   def weight_for amount
        #     return @constant if amount < 1
        #     @constant + Math.log(amount).round(3)
        #   end
        # end
        # def install_without_constant
        #   def weight_for amount
        #     return 0 if amount < 1
        #     Math.log(amount).round 3
        #   end
        # end
        
      end

    end

  end

end