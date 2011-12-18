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
            if respond_to? :name
              location = ' for '
              if @index
                location += "#{@index.name}:#{name}"
              else
                location += "#{name}"
              end
            else
              location = ''
            end
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