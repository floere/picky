require 'spec_helper'

describe Picky::Wrappers::Bundle::Calculation do

  before(:each) do
    @bundle = double :bundle
    @calculation = described_class.new @bundle
  end

  describe 'ids' do
    it 'calls bundle#ids correctly' do
      @bundle.should_receive(:ids).once.with '0.0'

      @calculation.ids 'some_str'
    end
    it 'calls bundle#ids correctly' do
      @bundle.should_receive(:ids).once.with '6.28'

      @calculation.ids '6.28'
    end
  end

  describe 'weight' do
    it 'calls bundle#ids correctly' do
      @bundle.should_receive(:weight).once.with '0.0'

      @calculation.weight 'some_str'
    end
    it 'calls bundle#ids correctly' do
      @bundle.should_receive(:weight).once.with '6.28'

      @calculation.weight '6.28'
    end
  end

end