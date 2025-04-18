require 'spec_helper'

describe Picky::Loggers::Verbose do
  let(:index) { Picky::Index.new :some_index }
  let(:category) { Picky::Category.new :some_category, index }
  let(:file) { double :file, path: 'some/path' }
  let(:io) { StringIO.new }
  let(:logger) { described_class.new thing }
  context 'with Logger' do
    let(:thing) { Logger.new io }
    before :each do
      # Explicitly define formatting for these specs.
      #
      thing.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
    end
    describe 'more complicated test case' do
      it 'is correct' do
        Time.stub now: Time.new('0000')

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
  context 'with IO' do
    let(:thing) { io }
    describe 'more complicated test case' do
      it 'is correct' do
        Time.stub now: Time.new('0000')

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
end
