require 'spec_helper'

describe Internals::Indexing::Bundle::SuperBase do

  before(:each) do
    @configuration = stub :configuration, :identifier => 'some_identifier'
    Internals::Index::Files.stub! :new
    @similarity = Similarity::DoubleMetaphone.new 3
    @bundle = described_class.new :some_name, @configuration, @similarity
  end
  
  describe 'identifier' do
    it 'is correct' do
      @bundle.identifier.should == 'some_identifier:some_name'
    end
  end
  
  describe 'similar' do
    before(:each) do
      @bundle.similarity = @similarity.generate_from( :dragon => [1,2,3], :dargon => [4,5,6] )
    end
    it 'returns the right similars (not itself)' do
      @bundle.similar(:dragon).should == [:dargon]
    end
    it 'returns the right similars' do
      @bundle.similar(:trkn).should == [:dragon, :dargon]
    end
    it 'performs' do
      performance_of { @bundle.similar(:dragon) }.should < 0.000075
    end
    it 'performs' do
      performance_of { @bundle.similar(:trkn) }.should < 0.00006
    end
  end
  
end