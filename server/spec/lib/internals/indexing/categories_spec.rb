require 'spec_helper'

describe Internals::Indexing::Categories do
  
  let(:categories) { described_class.new }

  describe 'to_s' do
    context 'no categories' do
      it 'outputs the right thing' do
        categories.to_s.should == ""
      end
    end
    context 'with categories' do
      before(:each) do
        index = stub :index, :name => :some_name
        categories << Internals::Indexing::Category.new(:some_name, index, :source => stub(:source))
      end
      it 'outputs the right thing' do
        categories.to_s.should == "  Category(some_name from some_name):\n  Exact:\n    Memory\n  Partial:\n    Memory\n"
      end
    end
  end
  
  describe 'find' do
    context 'no categories' do
      it 'raises on none existent category' do
        expect do
          categories.find :some_non_existent_name
        end.to raise_error(%Q{Index category "some_non_existent_name" not found. Possible categories: "".})
      end
    end
    context 'with categories' do
      before(:each) do
        index = stub :index, :name => :some_name
        @category = Internals::Indexing::Category.new(:some_name, index, :source => stub(:source))
        categories << @category
      end
      it 'returns it if found' do
        categories.find(:some_name).should == @category
      end
      it 'raises on none existent category' do
        expect do
          categories.find :some_non_existent_name
        end.to raise_error(%Q{Index category "some_non_existent_name" not found. Possible categories: "some_name".})
      end
    end
  end
  
end