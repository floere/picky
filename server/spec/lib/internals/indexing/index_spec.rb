require 'spec_helper'

describe Internals::Indexing::Index do
  
  context "with categories" do
    before(:each) do
      @source = stub :some_source
      
      @categories = stub :categories
      
      @index = described_class.new :some_name, @source
      @index.define_category :some_category_name1
      @index.define_category :some_category_name2
      
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
      described_class.new :some_name, @source
    end
  end
  
end