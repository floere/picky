module Picky
  module API
    module Category

      module Similarity

        def extract_similarity thing
          return Generators::Similarity::Default unless thing

          if thing.respond_to?(:encode) && thing.respond_to?(:prioritize)
            thing
          else
            raise <<-ERROR
similarity options for #{index_name}:#{name} should be either
* for example a Similarity::Phonetic.new(n), Similarity::Metaphone.new(n), Similarity::DoubleMetaphone.new(n) etc.
or
* an object that responds to #encoded(text) => encoded_text and #prioritize(array_of_encoded, encoded)
ERROR
          end
        end

      end

    end
  end
end