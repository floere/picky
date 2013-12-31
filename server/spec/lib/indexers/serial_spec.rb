require 'spec_helper'

describe Picky::Indexers::Serial do

  before(:each) do
    @tokenizer = double :tokenizer
    @source  = double :source
    @category  = double :category,
                      :identifier => :some_identifier,
                      :tokenizer => @tokenizer,
                      :source => @source

    @indexer = described_class.new @category
    @indexer.stub :timed_exclaim
  end

  describe "source" do
    it "returns the one given to is" do
      @indexer.source.should == @source
    end
  end

end