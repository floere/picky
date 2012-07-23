# encoding: utf-8
#
require 'spec_helper'

# This spec describes
#
describe 'facets' do

  describe 'simple example' do
    let(:index) {
      index = Picky::Index.new :facets do
        category :name
        category :surname
      end

      thing = Struct.new :id, :name, :surname
      index.add thing.new(1, 'fritz', 'hanke')
      index.add thing.new(2, 'kaspar', 'schiess')
      index.add thing.new(3, 'florian', 'hanke')
    
      index
    }
    let(:finder) { Picky::Search.new index }
    
    describe 'facets' do
      it 'is correct' do
        # Picky has 2 facets with different weights for surname.
        #
        index.facets(:surname).should == {
          'hanke' => 0.693,
          'schiess' => 0
        }
    
        # It has 3 facets with the same weight for name.
        #
        index.facets(:name).should == {
          'fritz' => 0,
          'kaspar' => 0,
          'florian' => 0
        }
        
        # Picky only selects facets with a weight >= the given one.
        #
        index.facets(:surname, more_than: 0.5).should == {
          'hanke' => 0.693
        }
      end
    end
  
    describe 'facets' do
      it 'filters them correctly' do
        # Passing in no filter query just returns the facets
        #
        finder.facets(:surname).should == {
          'hanke' => 0.693,
          'schiess' => 0.0
        }
        
        # It has two facets.
        #
        # TODO Rewrite API.
        #
        finder.facets(:name, filter: 'surname:hanke').should == {
          'fritz' => 0,
          'florian' => 0
        }
      end
    end
  end
  
  describe 'complex example' do
    let(:index) {
      index = Picky::Index.new :facets do
        category :name
        category :surname
        category :age_category
      end

      thing = Struct.new :id, :name, :surname, :age_category
      index.add thing.new(1, 'ursula', 'meier', 40)
      index.add thing.new(2, 'peter', 'meier', 45)
      index.add thing.new(3, 'peter', 'kunz', 40)
      index.add thing.new(4, 'peter', 'hanke', 40)
      index.add thing.new(5, 'annabelle', 'hanke', 35)
      index.add thing.new(5, 'hans', 'meier', 35)
    
      index
    }
    let(:finder) { Picky::Search.new index }
  
    describe 'facets' do
      it 'is correct' do
        # Picky has 2 facets with different weights for surname.
        #
        index.facets(:surname).should == {
          'hanke' => 0.693,
          'kunz' => 0.0,
          'meier' => 1.099
        }
    
        # It has 3 facets with the same weight for name.
        #
        index.facets(:name).should == {
          'annabelle' => 0.0,
          'hans' => 0.0,
          'peter' => 1.099,
          'ursula' => 0.0
        }
        
        # It has 1 facet with weight > 0.
        #
        index.facets(:name, more_than: 0).should == {
          'peter' => 1.099
        }
      end
    end
  
    describe 'facets' do
      it 'is fast enough' do
        performance_of {
          10.times { finder.facets(:age_category, filter: 'surname:meier name:peter') }
        }.should < 0.0025
      end
      it 'filters them correctly' do
        # It has one facet.
        #
        # TODO Fix problems with alternative qualifiers (like :age).
        #
        finder.facets(:age_category, filter: 'surname:meier name:peter').should == {
          '45' => 0
        }
        
        # It has two facets.
        #
        finder.facets(:surname, filter: 'age_category:40 name:peter').should == {
          'kunz' => 0.0,
          'hanke' => 0.693
        }
        
        # It has 1 facet > weight 0.
        #
        finder.facets(:surname, filter: 'age_category:40 name:peter', more_than: 0).should == {
          'hanke' => 0.693
        }
      end
    end
  end
end
