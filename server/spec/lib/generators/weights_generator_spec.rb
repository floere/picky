require 'spec_helper'

describe Picky::Generators::WeightsGenerator do

  context 'integration' do
    it 'should generate the correct values' do
      generator = described_class.new :a => Array.new(0),
                                      :b => Array.new(1),
                                      :c => Array.new(10),
                                      :d => Array.new(100),
                                      :e => Array.new(1000)

      result = generator.generate

      result[:c].should be_close 2.3, 0.011
      result[:d].should be_close 4.6, 0.011
      result[:e].should be_close 6.9, 0.011
    end
  end

end