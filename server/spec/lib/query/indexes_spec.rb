require 'spec_helper'

describe Query::Indexes do

  3.times do |i|
    n       = i + 1
    name    = :"index#{n}"
    indexed = :"indexed#{n}"
    let(name) { stub name, :indexed => stub(indexed) }
  end

  let(:indexes) { described_class.new index1, index2, index3 }
  
  describe 'combinations_type_for' do
    it 'returns a specific Combination for a specific input' do
      indexes.combinations_type_for([IndexAPI.new(:gu, :ga)]).should == Query::Combinations
    end
    it 'just works on the same types' do
      indexes.combinations_type_for([:blorf, :blarf]).should == Query::Combinations
    end
    it 'just uses standard combinations' do
      indexes.combinations_type_for([:blorf]).should == Query::Combinations
    end
    it 'raises on multiple types' do
      expect do
        indexes.combinations_type_for [:blorf, "blarf"]
      end.to raise_error(Query::Indexes::DifferentTypesError)
    end
    it 'raises with the right message on multiple types' do
      expect do
        indexes.combinations_type_for [:blorf, "blarf"]
      end.to raise_error("Currently it isn't possible to mix Symbol and String Indexes in the same Query.")
    end
  end
  
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
      
      indexes.expand_combinations_from(combinations).should == nil
    end
    it 'can handle empty combinations' do
      combinations = [[], [:a, :b, :c], []]
      
      indexes.expand_combinations_from(combinations).should == nil
    end
    it 'can handle totally empty combinations' do
      combinations = [[], [], []]
      
      indexes.expand_combinations_from(combinations).should == nil
    end
    it 'is fast in a complicated case' do
      combinations = [[1,2,3], [:a, :b, :c], [:k, :l]]

      performance_of { indexes.expand_combinations_from(combinations) }.should < 0.00055
    end
    it 'is fast in a simple case' do
      combinations = [[1], [2], [3]]

      performance_of { indexes.expand_combinations_from(combinations) }.should < 0.00055
    end
    it 'is very fast in a 1-empty case' do
      combinations = [[], [2], [3]]

      performance_of { indexes.expand_combinations_from(combinations) }.should < 0.00045
    end
    it 'is very fast in a all-empty case' do
      combinations = [[], [], []]

      performance_of { indexes.expand_combinations_from(combinations) }.should < 0.00045
    end
  end

end