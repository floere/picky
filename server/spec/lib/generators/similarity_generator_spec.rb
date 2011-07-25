require 'spec_helper'

describe Picky::Generators::SimilarityGenerator do

  context 'integration' do
    it 'should generate the correct values' do
      generator = described_class.new :anything_really

      generator.generate.should == {}
    end
    it 'should generate the correct values with a given strategy' do
      generator = described_class.new :meier => nil,
                                                  :maier => nil,
                                                  :mayer => nil,
                                                  :meyer => nil,
                                                  :peter => nil

      generator.generate(Picky::Generators::Similarity::DoubleMetaphone.new).should == { :MR => [:meier, :maier, :mayer, :meyer], :PTR => [:peter] }
    end
  end

end