# coding: utf-8
#
require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')
# require File.dirname(__FILE__) + '/data'

describe "Cases" do
  
  # 1. Load data into db.
  # 2. Index the data in the db.
  # 3. Cache it, and load into memory.
  #
  before(:all) do
    `cat data/generate_test_db.sql | sqlite3 data/test.db`
    Indexes.index
    Indexes.load_from_cache
  end
  
  def self.it_should_find_ids_in_main_full text, expected_ids
    it 'should return the right ids' do
      @full.search_with_text(text).ids.should == expected_ids
    end
  end
  def ids_of results
    results.serialize[:allocations].inject([]) { |ids, allocation| ids + allocation[4] }
  end
  
  before(:each) do
    @full = Query::Full.new Indexes[:main]
  end
  
  describe 'description' do
    it_should_find_ids_in_main_full 'Soledad', [1]
  end
  
end