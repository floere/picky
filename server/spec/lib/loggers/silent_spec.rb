require 'spec_helper'

describe Picky::Loggers::Silent do
  let(:io) { StringIO.new }
  let(:logger) { described_class.new thing }
  context 'with Logger' do
    let(:thing) { Logger.new io }
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

        io.string.should == ''
      end
    end
  end
  context 'with IO' do
    let(:thing) { io }
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

        io.string.should == ''
      end
    end
  end
end
