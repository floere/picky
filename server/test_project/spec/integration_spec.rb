# coding: utf-8
#
require 'spec_helper'

describe "Cases" do
  
  # 1. Load data into db.
  # 2. Index the data in the db.
  # 3. Cache it, and load into memory.
  #
  before(:all) do
    Indexes.load_from_cache
    @full = Query::Full.new Indexes[:csv_test]
  end
  
  def self.it_should_find_ids_in_main_full text, expected_ids
    it 'should return the right ids' do
      @full.search_with_text(text).ids.should == expected_ids
    end
  end
  def ids_of results
    results.serialize[:allocations].inject([]) { |ids, allocation| ids + allocation[4] }
  end
  
  describe 'test cases' do
    # Standard
    #
    it_should_find_ids_in_main_full 'Soledad Human', [72]
    it_should_find_ids_in_main_full 'First Three Minutes Weinberg', [1]
    
    # Partial
    #
    it_should_find_ids_in_main_full 'Gover* Systems', [7]
    it_should_find_ids_in_main_full 'A*', [2, 5, 21, 22, 23, 24, 27, 36, 39, 41, 47, 51, 71, 103, 110, 120, 149, 171, 213, 231]
    
    # Similarity
    #
    it_should_find_ids_in_main_full 'Hystori~ Leeward', [4, 4]
  end
  
end