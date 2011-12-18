require 'spec_helper'

describe Picky::API::Category::Similarity do
  let(:object) do
    Class.new do
      include Picky::API::Category::Similarity

      def index_name
        :some_index
      end
      def name
        :some_category
      end
    end.new
  end
  context 'encode' do
    context 'with nil' do
      it 'returns the default' do
        object.extract_similarity(nil).should == Picky::Similarity::Default
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
        object.extract_similarity(similarizer).encode('whatevs').should == :encoded
      end
    end
    context 'invalid weight' do
      it 'raises with a nice error message' do
        expect {
          object.extract_similarity Object.new
        }.to raise_error(<<-ERROR)
similarity options for some_index:some_category should be either
* for example a Similarity::Phonetic.new(n), Similarity::Metaphone.new(n), Similarity::DoubleMetaphone.new(n) etc.
or
* an object that responds to #encode(text) => encoded_text and #prioritize(array_of_encoded, encoded)
ERROR
      end
    end
  end
end