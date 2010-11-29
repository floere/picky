# coding: utf-8
#
require 'spec_helper'

describe "Integration Tests" do
  
  # 1. Load data into db.
  # 2. Index the data in the db.
  # 3. Cache it, and load into memory.
  #
  before(:all) do
    Indexes.index_for_tests
    Indexes.load_from_cache
    @csv = Query::Full.new Indexes[:csv_test]
    @geo = Query::Full.new Indexes[:geo]
  end
  
  def self.it_should_find_ids_in_csv text, expected_ids
    it 'should return the right ids' do
      @csv.search_with_text(text).ids.should == expected_ids
    end
  end
  def self.it_should_find_ids_in_geo text, expected_ids
    it 'should return the right ids' do
      @geo.search_with_text(text).ids.should == expected_ids
    end
  end
  def ids_of results
    results.serialize[:allocations].inject([]) { |ids, allocation| ids + allocation[4] }
  end
  
  describe 'test cases' do
    # Standard
    #
    it_should_find_ids_in_csv 'Soledad Human', [72]
    it_should_find_ids_in_csv 'First Three Minutes Weinberg', [1]
    
    # Complex cases
    #
    it_should_find_ids_in_csv 'title:le* title:hystoree~', [4, 250, 428]
    it_should_find_ids_in_csv 'Hystori~ author:ferg', []
    it_should_find_ids_in_csv 'Hystori~ author:fergu', [4, 4]
    it_should_find_ids_in_csv 'Hystori~ author:fergus', [4, 4]
    it_should_find_ids_in_csv 'author:fergus', [4]
    
    # Partial
    #
    it_should_find_ids_in_csv 'Gover* Systems', [7]
    it_should_find_ids_in_csv 'A*', [2, 3, 4, 5, 6, 7, 8, 15, 24, 27, 29, 35, 39, 52, 55, 63, 67, 76, 80, 101]
    it_should_find_ids_in_csv 'a* b* c* d* f', [110, 416]
    
    # Similarity
    #
    it_should_find_ids_in_csv 'Hystori~ Leeward', [4, 4]
    it_should_find_ids_in_csv 'Strutigic~ Guvurnance~', [7]
    
    # Qualifiers
    #
    it_should_find_ids_in_csv "title:history author:fergus", [4]
    
    # Splitting
    #
    it_should_find_ids_in_csv "history/fergus-history/fergus,history&fergus", [4, 4, 4, 4, 4, 4, 4, 4]
    
    # Character Removal
    #
    it_should_find_ids_in_csv "'(history)' '(fergus)'", [4, 4]
    
    # Contraction
    #
    # it_should_find_ids_in_csv ""
    
    # Stopwords
    #
    it_should_find_ids_in_csv "and the history or fergus", [4, 4]
    it_should_find_ids_in_csv "und and the or on of in is to from as at an history fergus", [4, 4]
    
    # Normalization
    #
    # it_should_find_ids_in_csv "Deoxyribonucleic Acid", []
    # it_should_find_ids_in_csv '800 dollars', []
    
    # Remove after splitting.
    #
    # it_should_find_ids_in_csv "history.fergus", [4, 4]
    
    # Character Substitution.
    #
    it_should_find_ids_in_csv "hïstôry Educåtioñ fërgus", [4, 4, 4, 4]
    
    # Breakage
    #
    it_should_find_ids_in_csv "%@{*^$!*$$^!&%!@%#!%#(#!@%#!#!)}", []
    it_should_find_ids_in_csv "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", []
    
    # Location based search.
    #
    it_should_find_ids_in_geo "north1:47.41,east1:8.55", [763,1413,10346,10661,10717,10746,10768,10861]
    
    # Categorization.
    #
    it 'uses categorization correctly' do
      @csv.search_with_text('t:religion').ids.should == @csv.search_with_text('title:religion').ids
    end
    it 'uses categorization' do
      @csv.search_with_text('title:religion').ids.should_not == @csv.search_with_text('subject:religion').ids
    end
  end
  
end