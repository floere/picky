module Picky
  module API

    module Tokenizer

      def extract_tokenizer thing
        return unless thing
        if thing.respond_to? :tokenize
          thing
        else
          if thing.respond_to? :[]
            Picky::Tokenizer.new thing
          else
            location = ''
            location += " for #{index_name}" if respond_to?(:index_name)
            location += ":#{name}" if respond_to?(:name)
            raise <<-ERROR
indexing options#{location} should be either
* a Hash
or
* an object that responds to #tokenize(text) => [[token1, ...], [original1, ...]]
ERROR
          end
        end
      end

    end

  end
end