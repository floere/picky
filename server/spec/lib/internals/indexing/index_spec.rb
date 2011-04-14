require 'spec_helper'

describe Internals::Indexing::Index do
  
  context "with categories" do
    before(:each) do
      @source = stub :some_source
      
      @index = described_class.new :some_name, source: @source
      @index.define_category :some_category_name1
      @index.define_category :some_category_name2
    end
    describe "raise_no_source" do
      it "should raise" do
        lambda { @index.raise_no_source }.should raise_error(NoSourceSpecifiedException)
      end
    end
    describe 'define_source' do
      it 'can be set with this method' do
        @index.define_source :some_other_source

        @index.source.should == :some_other_source
      end
    end
    describe "generate_caches" do
      it "delegates to each category" do
        category1 = stub :category1
        category2 = stub :category2
        
        @index.stub! :categories => [category1, category2]
        
        category1.should_receive(:generate_caches).once.ordered.with
        category2.should_receive(:generate_caches).once.ordered.with
        
        @index.generate_caches
      end
    end
    describe 'find' do
      context 'no categories' do
        it 'raises on none existent category' do
          expect do
            @index.find :some_non_existent_name
          end.to raise_error(%Q{Index category "some_non_existent_name" not found. Possible categories: "some_category_name1", "some_category_name2".})
        end
      end
      context 'with categories' do
        before(:each) do
          @index.define_category :some_name, :source => stub(:source)
        end
        it 'returns it if found' do
          @index.find(:some_name).should_not == nil
        end
        it 'raises on none existent category' do
          expect do
            @index.find :some_non_existent_name
          end.to raise_error(%Q{Index category "some_non_existent_name" not found. Possible categories: "some_category_name1", "some_category_name2", "some_name".})
        end
      end
    end
  end
  
  context "no categories" do
    it "works" do
      described_class.new :some_name, source: @source
    end
  end
  
end