require 'spec_helper'

describe Picky::API::Tokenizer do
  let(:object) do
    Class.new do
      include Picky::API::Tokenizer::Stemmer
    end.new
  end
  context 'extract_character_substituter' do
    context 'with a substituter' do
      let(:stemmer) do
        Class.new do
          def stem(text)
            text.gsub /computers/, 'comput' # a simple one word stemmer ;)
          end
        end.new
      end
      it 'creates a tokenizer' do
        object.extract_stemmer(stemmer)
              .stem('computers').should == 'comput'
      end
    end
    context 'invalid tokenizer' do
      it 'raises with a nice error message' do
        expect {
          object.extract_stemmer Object.new
        }.to raise_error(<<~ERROR)
          The stems_with option needs a stemmer,
          which responds to #stem(text) and returns stemmed_text."
        ERROR
      end
    end
  end
end
