require 'spec_helper'

describe Picky::Query::Boosts do

  context 'with boosts' do
    let(:boosts) do
      described_class.new [:test1, :test2]         => 6,
                          [:test1]                 => 5,
                          [:test3]                 => 3,
                          [:test3, :test2]         => 4,
                          [:test1, :test4]         => 5,
                          [:test4, :test1]         => 5,
                          [:test4, :test1, :test2] => 4,
                          [:test1, :test4, :test2] => 4,
                          [:test4, :test5]         => 3,
                          [:test5, :test1]         => 2,
                          [:test1, :test5]         => 2,
                          [:test3, :test1]         => 2,
                          [:test1, :test3]         => 2
    end

    describe 'boost_for' do
      it 'gets the category names from the combinations' do
        combinations = [
          double(:combination1, category_name: :test1),
          double(:combination1, category_name: :test2)
        ]

        boosts.boost_for(combinations).should == +6
      end
    end

    describe 'weight_for' do
      it 'should return zero if there is no specific weight' do
        boosts.boost_for_categories([:not_a_specific_allocation]).should be_zero
      end
    end

    def self.it_should_return_a_specific_boost_for(allocation, boost)
      it "should return boost #{boost} for #{allocation.inspect}" do
        boosts.boost_for_categories(allocation).should == boost
      end
    end

    it_should_return_a_specific_boost_for [:test1, :test2],         6
    it_should_return_a_specific_boost_for [:test1],                 5
    it_should_return_a_specific_boost_for [:test1, :test3],         2
    it_should_return_a_specific_boost_for [:test3],                 3
    it_should_return_a_specific_boost_for [:test3, :test2],         4
    it_should_return_a_specific_boost_for [:test1, :test4],         5
    it_should_return_a_specific_boost_for [:test4, :test1],         5
    it_should_return_a_specific_boost_for [:test4, :test1, :test2], 4
    it_should_return_a_specific_boost_for [:test1, :test4, :test2], 4
    it_should_return_a_specific_boost_for [:test4, :test5],         3
    it_should_return_a_specific_boost_for [:test5, :test1],         2
    it_should_return_a_specific_boost_for [:test1, :test5],         2
    it_should_return_a_specific_boost_for [:test3, :test1],         2

    describe 'to_s' do
      it 'is correct' do
        boosts.to_s.should == 'Picky::Query::Boosts({[:test1, :test2]=>6, [:test1]=>5, [:test3]=>3, [:test3, :test2]=>4, [:test1, :test4]=>5, [:test4, :test1]=>5, [:test4, :test1, :test2]=>4, [:test1, :test4, :test2]=>4, [:test4, :test5]=>3, [:test5, :test1]=>2, [:test1, :test5]=>2, [:test3, :test1]=>2, [:test1, :test3]=>2})'
      end
    end
    describe 'empty?' do
      it 'is correct' do
        boosts.empty?.should == false
      end
    end
  end
  context 'without boosts' do
    let(:boosts) { described_class.new }
    describe 'empty?' do
      it 'is correct' do
        boosts.empty?.should == true
      end
    end
  end

end
