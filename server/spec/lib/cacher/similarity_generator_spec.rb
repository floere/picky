require 'spec_helper'

describe Cacher::SimilarityGenerator do

  context 'integration' do
    it 'should generate the correct values' do
      generator = Cacher::SimilarityGenerator.new :anything_really

      generator.generate.should == {}
    end
    it 'should generate the correct values with a given strategy' do
      generator = Cacher::SimilarityGenerator.new :meier => nil,
                                                  :maier => nil,
                                                  :mayer => nil,
                                                  :meyer => nil,
                                                  :peter => nil

      generator.generate(Cacher::Similarity::DoubleLevenshtone.new).should == { :MR => [:meier, :maier, :mayer, :meyer], :PTR => [:peter] }
    end
  end

end