module Picky
  module API
    module Tokenizer
      module Stemmer
        def extract_stemmer(thing)
          raise ArgumentError, <<~ERROR unless thing.respond_to? :stem
            The stems_with option needs a stemmer,
            which responds to #stem(text) and returns stemmed_text."
          ERROR

          thing
        end
      end
    end
  end
end
