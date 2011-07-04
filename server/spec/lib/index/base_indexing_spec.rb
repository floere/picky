require 'spec_helper'

describe Index::Base do
  
  context "with categories" do
    before(:each) do
      @source = []
      
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
    describe 'find' do
      context 'no categories' do
        it 'raises on none existent category' do
          expect do
            @index[:some_non_existent_name]
          end.to raise_error(%Q{Index category "some_non_existent_name" not found. Possible categories: "some_category_name1", "some_category_name2".})
        end
      end
      context 'with categories' do
        before(:each) do
          @index.define_category :some_name, :source => stub(:source)
        end
        it 'returns it if found' do
          @index[:some_name].should_not == nil
        end
        it 'raises on none existent category' do
          expect do
            @index[:some_non_existent_name]
          end.to raise_error(%Q{Index category "some_non_existent_name" not found. Possible categories: "some_category_name1", "some_category_name2", "some_name".})
        end
      end
    end
  end
  
  context "no categories" do
    it "works" do
      described_class.new :some_name, source: []
    end
  end
  
end