require 'spec_helper'

describe Picky::Generators::Weights::Dynamic do
  context 'defined block' do
    let(:constant) { described_class.new { |str_or_sym| str_or_sym.size } }

    describe '[]' do
      it 'is the length of the given string' do
        constant[''].should == 0
      end
      it 'is the length of the given string' do
        constant['whatevs'].should == 7
      end
      it 'is the length of the given symbol' do
        constant[:whatever].should == 8
      end
    end

    describe 'weight_for' do
      it 'is nil' do
        constant.weight_for(1234).should == nil
      end
    end
  end
end
