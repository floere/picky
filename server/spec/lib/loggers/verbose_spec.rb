require 'spec_helper'

describe Picky::Loggers::Verbose do
  
  let(:io) { StringIO.new }
  let(:logger) { described_class.new io }

  describe 'more complicated test case' do
    it 'is correct' do
      index    = Picky::Index.new :some_index
      category = Picky::Category.new :some_category, index
      file = stub :file, :path => 'some/path'
      
      Time.stub! :now => Time.new('zeros')
      
      logger.info 'Tokenizing '
      logger.tokenize category, file
      logger.tokenize category, file
      logger.tokenize category, file
      logger.info ' Dumping '
      logger.dump category
      logger.dump category
      logger.info ' Loading '
      logger.load category
      logger.load category
      logger.load category
      logger.load category
      
      io.string.should == "00:00:00: Tokenizing \n00:00:00:   \"some_index:some_category\": Tokenized -> some/path.\n00:00:00:   \"some_index:some_category\": Tokenized -> some/path.\n00:00:00:   \"some_index:some_category\": Tokenized -> some/path.\n00:00:00:  Dumping \n00:00:00:   \"some_index:some_category\": Dumped -> index/test/some_index/some_category_*.\n00:00:00:   \"some_index:some_category\": Dumped -> index/test/some_index/some_category_*.\n00:00:00:  Loading \n00:00:00:   \"some_index:some_category\": Loading index from cache.\n00:00:00:   \"some_index:some_category\": Loading index from cache.\n00:00:00:   \"some_index:some_category\": Loading index from cache.\n00:00:00:   \"some_index:some_category\": Loading index from cache.\n"
    end
  end

end
