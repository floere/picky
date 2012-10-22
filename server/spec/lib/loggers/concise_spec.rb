require 'spec_helper'

describe Picky::Loggers::Concise do
  
  let(:io) { StringIO.new }
  let(:logger) { described_class.new thing }

  context 'with Logger' do
    let(:thing) { Logger.new io }
    describe 'more complicated test case' do
      it 'is correct' do
        logger.write 'Tokenizing '
        logger.tokenize :some_category
        logger.tokenize :some_category
        logger.tokenize :some_category
        logger.write ' Dumping '
        logger.dump :some_category
        logger.dump :some_category
        logger.write ' Loading '
        logger.load :some_category
        logger.load :some_category
        logger.load :some_category
        logger.load :some_category
      
        io.string.should == "Tokenizing TTT Dumping DD Loading ...."
      end
    end
  end
  context 'with IO' do
    let(:thing) { io }
    describe 'more complicated test case' do
      it 'is correct' do
        logger.write 'Tokenizing '
        logger.tokenize :some_category
        logger.tokenize :some_category
        logger.tokenize :some_category
        logger.write ' Dumping '
        logger.dump :some_category
        logger.dump :some_category
        logger.write ' Loading '
        logger.load :some_category
        logger.load :some_category
        logger.load :some_category
        logger.load :some_category
      
        io.string.should == 'Tokenizing TTT Dumping DD Loading ....'
      end
    end
  end

end
