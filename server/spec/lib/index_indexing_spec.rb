require 'spec_helper'

describe Picky::Index do

  describe 'tokenizer' do
    context 'with tokenizer' do
      let(:tokenizer) { stub :tokenizer, :tokenize => '' }
      let(:index) do
        the_tokenizer = tokenizer
        described_class.new :some_name do
          source []
          indexing the_tokenizer
        end
      end

      it 'does things in order' do
        index.tokenizer.should == tokenizer
      end
    end
    context 'without tokenizer' do
      let(:index) do
        described_class.new :some_name do
          source []
        end
      end

      it 'does things in order' do
        index.tokenizer.should == Picky::Indexes.tokenizer
      end
    end
  end

  context 'after_indexing' do
    context 'with it set' do
      let(:index) do
        described_class.new :some_name do
          after_indexing "some after indexing going on"
        end
      end
      it 'has an after_indexing set' do
        index.after_indexing.should == "some after indexing going on"
      end
    end
    context 'with it not set' do
      let(:index) do
        described_class.new :some_name do
        end
      end
      it 'does not have an after_indexing set' do
        index.after_indexing.should == nil
      end
    end
  end

  context 'in general' do
    context 'with #each source' do
      let(:index) do
        described_class.new :some_name
      end

      it 'does things in order' do
        scheduler = stub :scheduler, :fork? => false, :finish => nil

        index.should_receive(:prepare).once.with(scheduler).ordered
        index.should_receive(:cache).once.with(scheduler).ordered

        index.index scheduler
      end
    end
    context 'with non#each source' do
      it 'raises' do
        the_source = stub :source, :harvest => nil
        expect {
          described_class.new :some_name do
            source the_source
          end
        }.to raise_error(<<-ERROR)
The source for some_name should respond to either the method #each or
it can be a lambda/block, returning such a source.
ERROR
      end
    end
  end

  context "with categories" do
    before(:each) do
      the_source = []

      @index = described_class.new :some_name do
        source the_source
      end
      @index.category :some_category_name1
      @index.category :some_category_name2
    end
    describe 'source' do
      it 'can be set with this method' do
        source = stub :source, :each => [].each

        @index.source source

        @index.source.should == source
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
          @index.category :some_name, :source => stub(:source)
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
      described_class.new :some_name do
        source []
      end
    end
  end

end