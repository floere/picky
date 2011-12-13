require 'spec_helper'

describe Picky::Bundle do

  before(:each) do
    @index    = Picky::Index.new :some_index
    @category = Picky::Category.new :some_category, @index
    @weights    = Picky::Weights::Logarithmic.new
    @similarity = Picky::Similarity::DoubleMetaphone.new 3
  end
  let(:bundle) { described_class.new :some_name, @category, @weights, :some_partial, @similarity }

  describe 'identifier' do
    it 'should return a specific identifier' do
      bundle.identifier.should == :'some_index:some_category:some_name'
    end
  end

  describe 'similar' do
    before(:each) do
      bundle.add_similarity :dragon
      bundle.add_similarity :dargon
    end
    it 'returns the right similars (not itself)' do
      bundle.similar(:dragon).should == [:dargon]
    end
    it 'returns the right similars' do
      bundle.similar(:trkn).should == [:dragon, :dargon]
    end
    it 'performs' do
      performance_of { bundle.similar(:dragon) }.should < 0.000075
    end
    it 'performs' do
      performance_of { bundle.similar(:trkn) }.should < 0.00006
    end
  end

  describe 'dump' do
    it 'should trigger dumps' do
      bundle.stub! :timed_exclaim

      bundle.should_receive(:dump_inverted).once.with
      bundle.should_receive(:dump_weights).once.with
      bundle.should_receive(:dump_similarity).once.with
      bundle.should_receive(:dump_configuration).once.with

      bundle.dump
    end
  end



  describe 'initialization' do
    it 'should initialize the index correctly' do
      bundle.inverted.should == {}
    end
    it 'should initialize the weights index correctly' do
      bundle.weights.should == {}
    end
    it 'should initialize the similarity index correctly' do
      bundle.similarity.should == {}
    end
    it 'should initialize the configuration correctly' do
      bundle.configuration.should == {}
    end
    it 'should initialize the partial strategy correctly' do
      bundle.partial_strategy.should == :some_partial
    end
    it 'should initialize the weights strategy correctly' do
      bundle.weight_strategy.should == @weights
    end
    it 'should initialize the similarity strategy correctly' do
      bundle.similarity_strategy.should == @similarity
    end
  end

end