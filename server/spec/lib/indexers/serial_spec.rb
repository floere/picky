require 'spec_helper'

describe Picky::Indexers::Serial do

  before(:each) do
    @tokenizer = stub :tokenizer
    @source  = stub :source
    @category  = stub :category,
                      :identifier => :some_identifier,
                      :tokenizer => @tokenizer,
                      :source => @source

    @indexer = described_class.new @category
    @indexer.stub! :timed_exclaim
  end

  describe "source" do
    it "returns the one given to is" do
      @indexer.source.should == @source
    end
  end

end