require 'spec_helper'

describe Picky::Generators::Similarity do
  let(:similarity) { described_class } # "class", actually a module.
  context 'encode' do
    context 'with nil' do
      it 'returns the default' do
        similarity.from(nil).should == Picky::Similarity::Default
      end
    end
    context 'with a similarity object' do
      let(:similarizer) do
        Class.new do
          def encode text
            :encoded
          end
          def prioritize ary, encoded

          end
        end.new
      end
      it 'returns the encoded string' do
        similarity.from(similarizer).encode('whatevs').should == :encoded
      end
    end
    context 'invalid weight' do
      it 'raises with a nice error message' do
        expect {
          similarity.from Object.new
        }.to raise_error(<<-ERROR)
Similarity options should be either
* for example a Similarity::Soundex.new(n), Similarity::Metaphone.new(n), Similarity::DoubleMetaphone.new(n) etc.
or
* an object that responds to #encode(text) => encoded_text and #prioritize(array_of_encoded, encoded)
ERROR
      end
      it 'raises with a nice error message' do
        expect {
          similarity.from Object.new, 'some_index'
        }.to raise_error(<<-ERROR)
Similarity options for some_index should be either
* for example a Similarity::Soundex.new(n), Similarity::Metaphone.new(n), Similarity::DoubleMetaphone.new(n) etc.
or
* an object that responds to #encode(text) => encoded_text and #prioritize(array_of_encoded, encoded)
ERROR
      end
      it 'raises with a nice error message' do
        expect {
          similarity.from Object.new, 'some_index', 'some_category'
        }.to raise_error(<<-ERROR)
Similarity options for some_index:some_category should be either
* for example a Similarity::Soundex.new(n), Similarity::Metaphone.new(n), Similarity::DoubleMetaphone.new(n) etc.
or
* an object that responds to #encode(text) => encoded_text and #prioritize(array_of_encoded, encoded)
ERROR
      end
    end
  end
end