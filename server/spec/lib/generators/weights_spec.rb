require 'spec_helper'

describe Picky::Generators::Weights do
  let(:weights) { described_class } # "class", actually a module.
  context 'self.from' do
    context 'with nil' do
      it 'returns the default' do
        weights.from(nil).should == Picky::Weights::Default
      end
    end
    context 'with a number' do
      it 'returns a logarithmic weighter' do
        weights.from(7.3).should be_kind_of(Picky::Weights::Logarithmic)
      end
      it 'returns a logarithmic weighter' do
        weights.from(3.14).weight_for(10).should == 5.443 # ln(10) + 3.14 = 2.3025 + 3.14
      end
    end
    context 'with a weight object' do
      let(:weighter) do
        Class.new do
          def weight_for(_amount)
            7.0
          end
        end.new
      end
      it 'creates a tokenizer' do
        weights.from(weighter).weight_for(21).should == 7.0
      end
    end
    context 'invalid weight' do
      it 'raises with a nice error message' do
        expect do
          weights.from Object.new
        end.to raise_error(<<~ERROR)
          weight options should be either
          * for example a Weights::Logarithmic.new, Weights::Constant.new(int = 0), Weights::Dynamic.new(&block) etc.
          or
          * an object that responds to #weight_for(amount_of_ids_for_token) => float
        ERROR
      end
    end
    context 'invalid weight' do
      it 'raises with a nice error message' do
        expect do
          weights.from Object.new, 'some_index_name'
        end.to raise_error(<<~ERROR)
          weight options for some_index_name should be either
          * for example a Weights::Logarithmic.new, Weights::Constant.new(int = 0), Weights::Dynamic.new(&block) etc.
          or
          * an object that responds to #weight_for(amount_of_ids_for_token) => float
        ERROR
      end
    end
    context 'invalid weight' do
      it 'raises with a nice error message' do
        expect do
          weights.from Object.new, 'some_index_name', 'some_category_name'
        end.to raise_error(<<~ERROR)
          weight options for some_index_name:some_category_name should be either
          * for example a Weights::Logarithmic.new, Weights::Constant.new(int = 0), Weights::Dynamic.new(&block) etc.
          or
          * an object that responds to #weight_for(amount_of_ids_for_token) => float
        ERROR
      end
    end
  end
end
