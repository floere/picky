require 'spec_helper'

describe Internals::Indexed::Wrappers::ExactFirst do
  
  before(:each) do
    @exact    = stub :exact
    @partial  = stub :partial
    @category = stub :category, :exact => @exact, :partial => @partial
    
    @wrapper  = described_class.new @category
  end
  
  describe "self.wrap" do
    context "type" do
      # FIXME
      #
      # it "wraps each category" do
      #   type = Index::Type.new :type_name
      #   type.define_category :some_category
      #   
      #   Index::Wrappers::ExactFirst.wrap type
      #   
      #   type.categories.should be_kind_of(Index::Wrappers::ExactFirst)
      # end
      it "returns the type" do
        type = Indexed::Index.new :type_name
        type.define_category :some_category
        
        described_class.wrap(type).should == type
      end
    end
    context "category" do
      it "wraps each category" do
        category = stub :category, :exact => :exact, :partial => :partial
        
        described_class.wrap(category).should be_kind_of(Indexed::Wrappers::ExactFirst)
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