# encoding: utf-8
#
require 'spec_helper'

# This spec describes
#
describe 'facets' do
  
  describe 'with Redis' do
    let(:redis_index) {
      index = Picky::Index.new :redis_facets_index do
        backend Picky::Backends::Redis.new
        
        category :name
        category :surname
      end
      index.clear

      thing = Struct.new :id, :name, :surname
      index.add thing.new(1, 'fritz', 'hanke')
      index.add thing.new(2, 'kaspar', 'schiess')
      index.add thing.new(3, 'florian', 'hanke')
      
      index.dump
      index.load
    
      index
    }
    let(:redis_finder) { Picky::Search.new redis_index }
    
    describe 'Index#facets' do
      it 'does not fail' do
        redis_index.facets(:surname).should == {
          'hanke' => 2,
          'schiess' => 1
        }
      end
    end
    
    describe 'Search#facets' do
      it 'does not fail' do
        redis_finder.facets(:surname).should == {
          'hanke' => 2,
          'schiess' => 1
        }
      end
    end
  end

  describe 'simple example' do
    let(:index) {
      index = Picky::Index.new :facets do
        category :name, partial: Picky::Partial::Substring.new(from: 1)
        category :surname
      end

      thing = Struct.new :id, :name, :surname
      index.add thing.new(1, 'fritz', 'hanke')
      index.add thing.new(2, 'kaspar', 'schiess')
      index.add thing.new(3, 'florian', 'hanke')
    
      index
    }
    let(:finder) { Picky::Search.new index }
    
    describe 'Index#facets' do
      it 'is correct' do
        # Picky has 2 facets with different counts for surname.
        #
        index.facets(:surname).should == {
          'hanke' => 2,
          'schiess' => 1
        }
    
        # It has 3 facets with the same count for name.
        #
        index.facets(:name).should == {
          'fritz' => 1,
          'kaspar' => 1,
          'florian' => 1
        }
        
        # Picky only selects facets with a count >= the given one.
        #
        index.facets(:surname, at_least: 2).should == {
          'hanke' => 2
        }
      end
    end
  
    describe 'Search#facets' do
      it 'filters them correctly' do
        # Passing in no filter query just returns the facets
        #
        finder.facets(:surname).should == {
          'hanke' => 2,
          'schiess' => 1
        }
        
        # It has two facets.
        #
        finder.facets(:name, filter: 'surname:hanke').should == {
          'fritz' => 1,
          'florian' => 1
        }
        
        # It only uses exact matches (ie. the last token is not partialized).
        #
        finder.facets(:name, filter: 'surname:hank').should == {}
        
        # It allows explicit partial matches.
        #
        finder.facets(:name, filter: 'surname:hank*').should == {
          'fritz' => 1,
          'florian' => 1
        }
        
        # It allows explicit partial matches.
        #
        finder.facets(:name, filter: 'surname:hank*').should == {
          'fritz' => 1,
          'florian' => 1
        }
      end
    end
  end
  
  describe 'complex example' do
    let(:index) {
      index = Picky::Index.new :facets do
        category :name
        category :surname
        category :age_category, qualifier: :age
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
  
    describe 'Index#facets' do
      it 'has 2 facets with different counts for surname' do
        index.facets(:surname).should == {
          'hanke' => 2,
          'kunz' => 1,
          'meier' => 3
        }
      end
      it 'has 4 facets for the name' do
        index.facets(:name).should == {
          'annabelle' => 1,
          'hans' => 1,
          'peter' => 3,
          'ursula' => 1
        }
      end
      it 'has 3 facets with the same count for name' do
        index.facets(:name).should == {
          'annabelle' => 1,
          'hans' => 1,
          'peter' => 3,
          'ursula' => 1
        }
      end
      it 'has 1 facet with count >= 2' do
        index.facets(:name, at_least: 2).should == {
          'peter' => 3
        }
      end
    end
  
    describe 'Search#facets' do
      it 'is fast enough' do
        performance_of {
          10.times { finder.facets(:age_category, filter: 'surname:meier name:peter') }
        }.should < 0.0032
      end
      it 'has one filtered facet' do
        finder.facets(:age_category, filter: 'surname:meier name:peter').should == {
          '45' => 1
        }
      end
      it 'has two filtered facets' do
        finder.facets(:surname, filter: 'age:40 name:peter').should == {
          'kunz' => 1,
          'hanke' => 1 # Not 2 since it is filtered.
        }
      end
      it 'has 2 facets >= count 1' do
        finder.facets(:surname, filter: 'age:40 name:peter', at_least: 1).should == {
          'kunz' => 1,
          'hanke' => 1
        }
      end
      it 'has 0 facets >= counts 2' do
        finder.facets(:surname, filter: 'age:40 name:peter', at_least: 2).should == {}
      end
    end
    
    describe 'Search#facets without counts' do
      it 'is fast enough' do
        performance_of {
          10.times { finder.facets(:age_category, filter: 'surname:meier name:peter', counts: false) }
        }.should < 0.0031
      end
      it 'has one filtered facet' do
        finder.facets(:age_category, filter: 'surname:meier name:peter', counts: false).should == ['45']
      end
      it 'has two filtered facets' do
        finder.facets(:surname, filter: 'age:40 name:peter', counts: false).should == [
          'kunz',
          'hanke'
        ]
      end
      it 'has 2 facets >= count 1' do
        finder.facets(:surname, filter: 'age:40 name:peter', at_least: 1, counts: false).should == [
          'kunz',
          'hanke'
        ]
      end
      it 'has 0 facets >= counts 2' do
        finder.facets(:surname, filter: 'age:40 name:peter', at_least: 2, counts: false).should == []
      end
    end
    
    describe 'Search#facets with identical category text/filter text' do
      it 'does not report the same thing multiple times up to a limit' do
        require 'picky'
 
        shoe = Struct.new(:id, :color, :name)
 
        shoes_index = Picky::Index.new(:shoes) do
          category :color
          category :name
        end
 
        shoes_search = Picky::Search.new shoes_index
        
        shoes_index.add shoe.new(1, 'black', 'Outdoor Black')
        
        shoes_search.facets(:color).should == { 'black' => 1 }
        shoes_search.facets(:color, filter: 'black').should == { 'black' => 1 }
        
        999.times do |i|
          shoes_index.add shoe.new(i+2, 'black', 'Outdoor Black')
        end
 
        shoes_search.facets(:color).should == { 'black' => 1000 }
        shoes_search.facets(:color, filter: 'black').should == { 'black' => 1000 }
        
        # But then, over 1000 the count is only a very rough estimate.
        #
        500.times do |i|
          shoes_index.add shoe.new(i+1001, 'black', 'Outdoor Black')
        end
        
        shoes_search.facets(:color).should == { 'black' => 1500 }
        shoes_search.facets(:color, filter: 'black').should == { 'black' => 2000 }
      end
    end
    
  end
  
  describe 'simple example with symbols' do
    let(:index) {
      index = Picky::Index.new :facets do
        symbol_keys true
        category :name, partial: Picky::Partial::Substring.new(from: 1)
        category :surname
      end

      thing = Struct.new :id, :name, :surname
      index.add thing.new(1, 'fritz', 'hanke')
      index.add thing.new(2, 'kaspar', 'schiess')
      index.add thing.new(3, 'florian', 'hanke')
    
      index
    }
    let(:finder) do
      Picky::Search.new(index) { symbol_keys }
    end
    
    describe 'Index#facets' do
      it 'is correct' do
        # Picky has 2 facets with different counts for surname.
        #
        index.facets(:surname).should == {
          hanke: 2,
          schiess: 1
        }
    
        # It has 3 facets with the same count for name.
        #
        index.facets(:name).should == {
          fritz: 1,
          kaspar: 1,
          florian: 1
        }
        
        # Picky only selects facets with a count >= the given one.
        #
        index.facets(:surname, at_least: 2).should == {
          hanke: 2
        }
      end
    end
  
    describe 'Search#facets' do
      it 'filters them correctly' do
        # Passing in no filter query just returns the facets
        #
        finder.facets(:surname).should == {
          hanke: 2,
          schiess: 1
        }
        
        # It has two facets.
        #
        finder.facets(:name, filter: 'surname:hanke').should == {
          fritz: 1,
          florian: 1
        }
        
        # It only uses exact matches (ie. the last token is not partialized).
        #
        finder.facets(:name, filter: 'surname:hank').should == {}
        
        # It allows explicit partial matches.
        #
        finder.facets(:name, filter: 'surname:hank*').should == {
          fritz: 1,
          florian: 1
        }
        
        # It allows explicit partial matches.
        #
        finder.facets(:name, filter: 'surname:hank*').should == {
          fritz: 1,
          florian: 1
        }
      end
    end
  end
end
