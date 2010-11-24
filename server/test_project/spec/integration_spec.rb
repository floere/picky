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
    
    # Complex cases
    #
    it_should_find_ids_in_main_full 'title:le* title:hystoree~', [4, 250, 428]
    it_should_find_ids_in_main_full 'Hystori~ author:ferg', []
    it_should_find_ids_in_main_full 'Hystori~ author:fergu', [4, 4]
    it_should_find_ids_in_main_full 'Hystori~ author:fergus', [4, 4]
    it_should_find_ids_in_main_full 'author:fergus', [4]
    
    # Partial
    #
    it_should_find_ids_in_main_full 'Gover* Systems', [7]
    it_should_find_ids_in_main_full 'A*', [2, 3, 4, 5, 6, 7, 8, 15, 24, 27, 29, 35, 39, 52, 55, 63, 67, 76, 80, 101]
    it_should_find_ids_in_main_full 'a* b* c* d* f', [110, 416]
    
    # Similarity
    #
    it_should_find_ids_in_main_full 'Hystori~ Leeward', [4, 4]
    it_should_find_ids_in_main_full 'Strutigic~ Guvurnance~', [7]
    
    # Qualifiers
    #
    it_should_find_ids_in_main_full "title:history author:fergus", [4]
    
    # Splitting
    #
    it_should_find_ids_in_main_full "history/fergus-history/fergus,history&fergus", [4, 4, 4, 4, 4, 4, 4, 4]
    
    # Character Removal
    #
    it_should_find_ids_in_main_full "'(history)' '(fergus)'", [4, 4]
    
    # Contraction
    #
    # it_should_find_ids_in_main_full ""
    
    # Stopwords
    #
    it_should_find_ids_in_main_full "and the history or fergus", [4, 4]
    it_should_find_ids_in_main_full "und and the or on of in is to from as at an history fergus", [4, 4]
    
    # Normalization
    #
    # it_should_find_ids_in_main_full "Deoxyribonucleic Acid", []
    # it_should_find_ids_in_main_full '800 dollars', []
    
    # Remove after splitting.
    #
    # it_should_find_ids_in_main_full "history.fergus", [4, 4]
    
    # Character Substitution.
    #
    it_should_find_ids_in_main_full "hïstôry Educåtioñ fërgus", [4, 4, 4, 4]
    
    # Breakage
    #
    it_should_find_ids_in_main_full "%@{*^$!*$$^!&%!@%#!%#(#!@%#!#!)}", []
    it_should_find_ids_in_main_full "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", []
  end
  
end