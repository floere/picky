require 'spec_helper'

describe Indexed::Index do
  
  context 'without stubbed categories' do
    before(:each) do
      @index = Indexed::Index.new :some_index_name
    end
    
    describe 'define_category' do
      it 'adds a new category to the categories' do
        @index.define_category :some_category_name
        
        @index.categories.categories.size.should == 1 
      end
      it 'returns the new category' do
        @index.define_category(:some_category_name).should be_kind_of(Indexed::Category)
      end
    end
  end
  
  context "with stubbed categories" do
    before(:each) do
      @categories = stub :categories
      
      @index = Indexed::Index.new :some_name
      @index.define_category :some_category_name1
      @index.define_category :some_category_name2
      
      @index.stub! :categories => @categories
    end
    
    describe "load_from_cache" do
      it "delegates to each category" do
        @categories.should_receive(:load_from_cache).once.with
        
        @index.load_from_cache
      end
    end
    describe "possible_combinations" do
      it "delegates to the combinator" do
        @categories.should_receive(:possible_combinations_for).once.with :some_token
        
        @index.possible_combinations :some_token
      end
    end
  end
  
  context "no categories" do
    it "works" do
      Indexed::Index.new :some_name
    end
  end
  
end