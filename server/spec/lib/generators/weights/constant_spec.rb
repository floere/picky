require 'spec_helper'

describe Picky::Generators::Weights::Constant do
  context 'default weight' do
    let(:constant) { described_class.new }

    describe '[]' do
      it 'is always 0.0' do
        constant[:whatevs].should == 0.0
      end
    end

    describe 'weight_for' do
      it 'is 0.0' do
        constant.weight_for(1234).should == 0.0
      end
    end
  end

  context 'defined weight' do
    let(:constant) { described_class.new 3.14 }

    describe '[]' do
      it 'is always the defined weight' do
        constant[:whatevs].should == 3.14
      end
    end

    describe 'weight_for' do
      it 'is always the defined weight' do
        constant.weight_for(1234).should == 3.14
      end
    end
  end
end
