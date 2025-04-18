require 'spec_helper'

describe Picky::Indexers::Parallel do
  
  thing = Struct.new :id, :text

  before(:each) do
    @index = Picky::Index.new(:test) # double :index, :name => :some_index, :source => @source, :backend => double(:backend)
    @indexer = described_class.new @index
    @indexer.stub :timed_exclaim
  end
  
  context 'with untokenized category' do
    
    before(:each) do
      @categories = [
        Picky::Category.new(:text, @index)
      ]
      @source = [
        thing.new(1, 'hello'),
        thing.new(2, 'world'),
      ]
    end

    describe 'flush' do
      it 'flushes to joined cache to the file and clears it' do
        cache = double :cache
        file  = double :file

        cache.should_receive(:join).once.and_return :joined
        file.should_receive(:write).once.with(:joined).and_return :joined
        cache.should_receive(:clear).once

        @indexer.flush file, cache
      end
    end
  
    describe 'process' do
      it 'flushes to joined cache to the file and clears it' do
        @indexer.process @source, @categories do |file|
          file.path.should == 'spec/temp/index/test/test/text.prepared.txt'
        end
      end
    end
    
  end
  
  context 'with tokenized category' do
    
    before(:each) do
      @categories = [
        Picky::Category.new(:text, @index, tokenize: false)
      ]
      @source = [
        thing.new(1, ['hello']),
        thing.new(2, ['world']),
      ]
    end

    describe 'flush' do
      it 'flushes to joined cache to the file and clears it' do
        cache = double :cache
        file  = double :file

        cache.should_receive(:join).once.and_return :joined
        file.should_receive(:write).once.with(:joined).and_return :joined
        cache.should_receive(:clear).once

        @indexer.flush file, cache
      end
    end
  
    describe 'process' do
      it 'flushes to joined cache to the file and clears it' do
        @indexer.process @source, @categories do |file|
          file.path.should == 'spec/temp/index/test/test/text.prepared.txt'
        end
      end
    end
    
  end

end
