require 'spec_helper'

describe Indexing::Type do
  
  context "with categories" do
    before(:each) do
      @source = stub :some_source
      
      @categories = stub :categories
      
      @index = Indexing::Type.new :some_name, @source
      @index.add_category :some_category_name1
      @index.add_category :some_category_name2
      
      @index.stub! :categories => @categories
    end
    describe "generate_caches" do
      it "delegates to each category" do
        @categories.should_receive(:generate_caches).once.with
        
        @index.generate_caches
      end
    end
  end
  
  context "no categories" do
    it "works" do
      Indexing::Type.new :some_name, @source
    end
  end
  
end