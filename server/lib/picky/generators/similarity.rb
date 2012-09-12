module Picky
  
  module Generators

    module Similarity

      def self.from thing, index_name = nil, category_name = nil
        return Default unless thing

        if thing.respond_to?(:encode) && thing.respond_to?(:prioritize)
          thing
        else
          specifics = ""
          specifics << index_name if index_name
          specifics << ":#{category_name}" if category_name
          specifics = "for #{specifics} " unless specifics.empty?
          raise <<-ERROR
similarity options #{specifics}should be either
* for example a Similarity::Phonetic.new(n), Similarity::Metaphone.new(n), Similarity::DoubleMetaphone.new(n) etc.
or
* an object that responds to #encode(text) => encoded_text and #prioritize(array_of_encoded, encoded)
ERROR
        end
      end

    end

  end
  
end