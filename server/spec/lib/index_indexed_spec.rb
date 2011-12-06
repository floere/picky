require 'spec_helper'

describe Picky::Index do

  context 'without stubbed categories' do
    before(:each) do
      @index = described_class.new :some_index_name
    end

    describe 'category' do
      it 'adds a new category to the categories' do
        @index.category :some_category_name

        @index.categories.categories.size.should == 1
      end
      it 'returns the new category' do
        @index.category(:some_category_name).should be_kind_of(Picky::Category)
      end
    end
  end

  context "with stubbed categories" do
    before(:each) do
      @categories = stub :categories

      @index = described_class.new :some_name
      @index.category :some_category_name1
      @index.category :some_category_name2

      @index.stub! :categories => @categories
    end

    describe "load" do
      it "delegates to each category" do
        @categories.should_receive(:load).once.with

        @index.load
      end
    end
    describe "possible_combinations" do
      it "delegates to the combinator" do
        @categories.should_receive(:possible_combinations).once.with :some_token

        @index.possible_combinations :some_token
      end
    end
  end

  context 'result_identifier' do
    context 'with it set' do
      let(:index) do
        described_class.new :some_name do
          result_identifier :some_identifier
        end
      end
      it 'has an after_indexing set' do
        index.result_identifier.should == :some_identifier
      end
    end
    context 'with it not set' do
      let(:index) do
        described_class.new :some_name do
        end
      end
      it 'returns the name' do
        index.result_identifier.should == :some_name
      end
    end
  end

  context "no categories" do
    it "works" do
      described_class.new :some_name
    end
  end

end