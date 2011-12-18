module Picky
  module API
    module Search

      module Boost

        def extract_boosts thing
          if thing.respond_to?(:boost_for)
            thing
          else
            if thing.respond_to?(:[])
              Query::Boosts.new thing
            else
              raise <<-ERROR
boost options for a Search should be either
* for example a Hash { [:name, :surname] => +3 }
or
* an object that responds to #boost_for(combinations) and returns a boost float
ERROR
            end
          end
        end

      end

    end
  end
end