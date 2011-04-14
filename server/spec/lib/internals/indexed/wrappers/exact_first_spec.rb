require 'spec_helper'

describe Internals::Indexed::Wrappers::ExactFirst do
  
  before(:each) do
    @exact    = stub :exact
    @partial  = stub :partial
    @category = stub :category, :exact => @exact, :partial => @partial
    
    @wrapper  = described_class.new @category
  end
  
  describe "self.wrap" do
    context "index" do
      it "wraps each category" do
        index = Internals::Indexed::Index.new :index_name
        index.define_category :some_category
        
        Internals::Indexed::Wrappers::ExactFirst.wrap index
        
        index.categories.categories.each do |category|
          category.should be_kind_of(Internals::Indexed::Wrappers::ExactFirst)
        end
      end
      it "returns the index" do
        index = Internals::Indexed::Index.new :index_name
        index.define_category :some_category
        
        described_class.wrap(index).should == index
      end
    end
    context "category" do
      it "wraps each category" do
        category = stub :category, :exact => :exact, :partial => :partial
        
        described_class.wrap(category).should be_kind_of(described_class)
      end
    end
  end
  
  describe 'ids' do
    it "uses first the exact, then the partial ids" do
      @exact.stub!   :ids => [1,4,5,6]
      @partial.stub! :ids => [2,3,7]
      
      @wrapper.ids(:anything).should == [1,4,5,6,2,3,7]
    end
  end
  
  describe 'weight' do
    context "exact with weight" do
      before(:each) do
        @exact.stub! :weight => 1.23
      end
      context "partial with weight" do
        before(:each) do
          @partial.stub! :weight => 0.12
        end
        it "uses the higher weight" do
          @wrapper.weight(:anything).should == 1.23
        end
      end
      context "partial without weight" do
        before(:each) do
          @partial.stub! :weight => nil
        end
        it "uses the exact weight" do
          @wrapper.weight(:anything).should == 1.23
        end
      end
    end
    context "exact without weight" do
      before(:each) do
        @exact.stub! :weight => nil
      end
      context "partial with weight" do
        before(:each) do
          @partial.stub! :weight => 0.12
        end
        it "uses the partial weight" do
          @wrapper.weight(:anything).should == 0.12
        end
      end
      context "partial without weight" do
        before(:each) do
          @partial.stub! :weight => nil
        end
        it "is zero" do
          @wrapper.weight(:anything).should == 0
        end
      end
    end
  end
  
end