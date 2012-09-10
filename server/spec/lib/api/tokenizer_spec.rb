require 'spec_helper'

describe Picky::API::Tokenizer do
  let(:object) do
    Class.new do
      include Picky::API::Tokenizer
    end.new
  end
  context 'extract_tokenizer' do
    context 'options hash' do
      it 'creates a tokenizer' do
        object.extract_tokenizer(splits_text_on: /\t/).
          tokenize("hello\tworld").should == [['hello', 'world'], ['hello', 'world']]
      end
    end
    context 'tokenizer' do
      let(:tokenizer) do
        Class.new do
          def tokenize text
            ['unmoved', 'by', 'your', 'texts']
          end
        end.new
      end
      it 'creates a tokenizer' do
        object.extract_tokenizer(tokenizer).
          tokenize("hello\tworld").should == ['unmoved', 'by', 'your', 'texts']
      end
    end
    context 'invalid tokenizer' do
      it 'raises with a nice error message' do
        expect {
          object.extract_tokenizer Object.new
        }.to raise_error(<<-ERROR)
indexing options should be either
* a Hash
or
* an object that responds to #tokenize(text) => [[token1, ...], [original1, ...]]
ERROR
      end
    end
  end
end