require 'spec_helper'

describe Index::Type do
  
  context "with categories" do
    before(:each) do
      @some_type1 = stub :some_type1, :name => :some_type1
      @some_type2 = stub :some_type2, :name => :some_type2
      
      @category1 = Index::Category.new :some_category_name1, @some_type1
      @category2 = Index::Category.new :some_category_name2, @some_type2
      
      @index = Index::Type.new :some_name, :some_result_type, false, @category1, @category2
    end
    describe "generate_caches" do
      it "delegates to each category" do
        @category1.should_receive(:generate_caches).once.with
        @category2.should_receive(:generate_caches).once.with
        
        @index.generate_caches
      end
    end
    describe "load_from_cache" do
      it "delegates to each category" do
        @category1.should_receive(:load_from_cache).once.with
        @category2.should_receive(:load_from_cache).once.with
        
        @index.load_from_cache
      end
    end
  end
  
  context "no categories" do
    before(:each) do
      @combinator = stub :combinator
      Query::Combinator.stub! :new => @combinator
      
      @index = Index::Type.new :some_name, :some_result_type, false
    end
    
    describe "possible_combinations" do
      it "delegates to the combinator" do
        @combinator.should_receive(:possible_combinations_for).once.with :some_token
        
        @index.possible_combinations :some_token
      end
    end
  end
  
end