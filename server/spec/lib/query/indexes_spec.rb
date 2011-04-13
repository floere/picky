require 'spec_helper'

describe Internals::Query::Indexes do

  3.times do |i|
    n       = i + 1
    name    = :"index#{n}"
    indexed = :"indexed#{n}"
    let(name) { stub name, :internal_indexed => stub(indexed) }
  end

  let(:indexes) { described_class.new index1, index2, index3 }
  
  describe 'expand_combinations_from' do
    it 'generates all possible combinations from the given ones' do
      combinations = [[1,2,3], [:a, :b, :c], [:k, :l]]

      indexes.expand_combinations_from(combinations).should == [
        [1, :a, :k],
        [1, :a, :l],
        [1, :b, :k],
        [1, :b, :l],
        [1, :c, :k],
        [1, :c, :l],
        [2, :a, :k],
        [2, :a, :l],
        [2, :b, :k],
        [2, :b, :l],
        [2, :c, :k],
        [2, :c, :l],
        [3, :a, :k],
        [3, :a, :l],
        [3, :b, :k],
        [3, :b, :l],
        [3, :c, :k],
        [3, :c, :l]
      ]
    end
    it 'can handle small combinations' do
      combinations = [[1], [2], [3]]
      
      indexes.expand_combinations_from(combinations).should == [[1, 2, 3]]
    end
    it 'can handle empty combinations' do
      combinations = [[1,2,3], [:a, :b, :c], []]
      
      indexes.expand_combinations_from(combinations).should == []
    end
    it 'can handle empty combinations' do
      combinations = [[], [:a, :b, :c], []]
      
      indexes.expand_combinations_from(combinations).should == []
    end
    it 'can handle totally empty combinations' do
      combinations = [[], [], []]
      
      indexes.expand_combinations_from(combinations).should == []
    end
    it 'is fast in a complicated case' do
      combinations = [[1,2,3], [:a, :b, :c], [:k, :l]]

      performance_of { indexes.expand_combinations_from(combinations) }.should < 0.00055
    end
    it 'is fast in a simple case' do
      combinations = [[1], [2], [3]]

      performance_of { indexes.expand_combinations_from(combinations) }.should < 0.0006
    end
    it 'is very fast in a 1-empty case' do
      combinations = [[], [2], [3]]

      performance_of { indexes.expand_combinations_from(combinations) }.should < 0.0005
    end
    it 'is very fast in a all-empty case' do
      combinations = [[], [], []]

      performance_of { indexes.expand_combinations_from(combinations) }.should < 0.00045
    end
  end
  
  describe 'prepared_allocations_for' do
    before(:each) do
      @allocations = stub :allocations
      indexes.stub! :allocations_for => @allocations
    end
    it 'calls the right method in order' do
      @allocations.should_receive(:uniq).once.ordered.with()
      @allocations.should_receive(:calculate_score).once.ordered.with(:some_weights)
      @allocations.should_receive(:sort!).once.ordered.with()
      
      indexes.prepared_allocations_for :some_tokens, :some_weights
    end
    it 'calls the right method in order' do
      @allocations.should_receive(:uniq).once.ordered.with()
      @allocations.should_receive(:calculate_score).once.ordered.with({})
      @allocations.should_receive(:sort!).once.ordered.with()
      
      indexes.prepared_allocations_for :some_tokens
    end
  end

end