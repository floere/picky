module Picky
  module API
    module Tokenizer

      module Stemmer

        def extract_stemmer thing
          if thing.respond_to? :stem
            thing
          else
            raise ArgumentError.new <<-ERROR
The stems_with option needs a stemmer,
which responds to #stem(text) and returns stemmed_text."
ERROR
          end
        end

      end

    end
  end
end