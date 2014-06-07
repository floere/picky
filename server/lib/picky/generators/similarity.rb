module Picky

  module Generators

    module Similarity
      extend Helpers::Identification

      def self.from thing, index_name = nil, category_name = nil
        return Default unless thing

        if thing.respond_to?(:encode) && thing.respond_to?(:prioritize)
          thing
        else
          raise <<-ERROR
Similarity options #{identifier_for(index_name, category_name)}should be either
* for example a Similarity::Soundex.new(n), Similarity::Metaphone.new(n), Similarity::DoubleMetaphone.new(n) etc.
or
* an object that responds to #encode(text) => encoded_text and #prioritize(array_of_encoded, encoded)
ERROR
        end
      end

    end

  end

end