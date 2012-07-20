require 'spec_helper'

describe Picky::API::Category::Weight do
  let(:object) do
    Class.new do
      include Picky::API::Category::Weight

      def index_name
        :some_index
      end
      def name
        :some_category
      end
    end.new
  end
  context 'extract_weight' do
    context 'with nil' do
      it 'returns the default' do
        object.extract_weight(nil).should == Picky::Weights::Default
      end
    end
    context 'with a number' do
      it 'returns a logarithmic weighter' do
        object.extract_weight(7.3).should be_kind_of(Picky::Weights::Logarithmic)
      end
      it 'returns a logarithmic weighter' do
        object.extract_weight(3.14).weight_for(10).should == 5.443 # ln(10) + 3.14 = 2.3025 + 3.14
      end
    end
    context 'with a weight object' do
      let(:weighter) do
        Class.new do
          def weight_for amount
            7.0
          end
        end.new
      end
      it 'creates a tokenizer' do
        object.extract_weight(weighter).weight_for(21).should == 7.0
      end
    end
    context 'invalid weight' do
      it 'raises with a nice error message' do
        expect {
          object.extract_weight Object.new
        }.to raise_error(<<-ERROR)
weight options for some_index:some_category should be either
* for example a Weights::Logarithmic.new, Weights::Constant.new(int = 0), Weights::Dynamic.new(&block) etc.
or
* an object that responds to #weight_for(amount_of_ids_for_token) => float
ERROR
      end
    end
  end
end