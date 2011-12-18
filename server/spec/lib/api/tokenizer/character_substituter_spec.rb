require 'spec_helper'

describe Picky::API::Tokenizer do
  let(:object) do
    Class.new do
      include Picky::API::Tokenizer::CharacterSubstituter
    end.new
  end
  context 'extract_character_substituter' do
    context 'with a substituter' do
      let(:substituter) do
        Class.new do
          def substitute text
            text.tr('a-z', '1-9')
          end
        end.new
      end
      it 'creates a tokenizer' do
        object.extract_character_substituter(substituter).
          substitute("picky").should == '99399'
      end
    end
    context 'invalid tokenizer' do
      it 'raises with a nice error message' do
        expect {
          object.extract_character_substituter Object.new
        }.to raise_error(<<-ERROR)
The substitutes_characters_with option needs a character substituter,
which responds to #substitute(text) and returns substituted_text."
ERROR
      end
    end
  end
end