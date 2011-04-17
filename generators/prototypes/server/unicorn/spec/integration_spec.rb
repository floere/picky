# coding: utf-8
#
require 'spec_helper'
require 'picky-client/spec'

describe 'Integration Tests' do
  
  before(:all) do
    Indexes.index_for_tests
    Indexes.load_from_cache
  end
  
  let(:books) { Picky::TestClient.new(PickySearch, :path => '/books') }

  # Testing a count of results.
  #
  it { books.search('a s').total.should == 42 }
  
  # Testing a specific order of result ids.
  #
  it { books.search('alan').ids.should == [259, 307, 449] }
  
  # Testing an order of result categories.
  #
  it { books.search('alan').should have_categories(['author'], ['title']) }
  it { books.search('alan p').should have_categories(['author', 'title'], ['title', 'author']) }
  
end