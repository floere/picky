require 'spec_helper'

describe Picky::Loggers::Concise do
  
  let(:io) { StringIO.new }
  let(:logger) { described_class.new io }

  describe 'more complicated test case' do
    it 'is correct' do
      logger.info 'Tokenizing '
      logger.tokenize :some_category
      logger.tokenize :some_category
      logger.tokenize :some_category
      logger.info ' Dumping '
      logger.dump :some_category
      logger.dump :some_category
      logger.info ' Loading '
      logger.load :some_category
      logger.load :some_category
      logger.load :some_category
      logger.load :some_category
      
      io.string.should == 'Tokenizing TTT Dumping DD Loading ....'
    end
  end

end
