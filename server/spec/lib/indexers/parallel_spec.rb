require 'spec_helper'

describe Picky::Indexers::Parallel do

  before(:each) do
    @source     = stub :source
    @index      = stub :index, :name => :some_index, :source => @source

    @categories = stub :categories

    @indexer = described_class.new @index
    @indexer.stub! :timed_exclaim
  end

  describe 'flush' do
    it 'flushes to joined cache to the file and clears it' do
      cache = stub :cache
      file  = stub :file

      cache.should_receive(:join).once.and_return :joined
      file.should_receive(:write).once.with(:joined).and_return :joined
      cache.should_receive(:clear).once

      @indexer.flush file, cache
    end
  end

end