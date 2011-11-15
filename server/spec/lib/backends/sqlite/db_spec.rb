require 'spec_helper'

describe Picky::Backends::Sqlite::DB do

  context 'hash-based indexes' do
    let(:db) { described_class.new 'some/cache/path/to/file' }

    describe "dump" do
      it "delegates to the given hash" do
        hash = stub :hash

        db.should_receive(:dump_sqlite).once.with hash

        db.dump hash
      end
    end

    describe 'to_s' do
      it 'returns the cache path with the default file extension' do
        db.to_s.should == 'Picky::Backends::Sqlite::DB(some/cache/path/to/file.sqlite3)'
      end
    end
  end

end
